local Config = require("lzl.config")
local Handler = require("lzl.lzl_handler")
local Plugin = require("lzl.plugin")
local Util = require("lzl.util")
local Cache = vim.loader

---@class LzlCoreLoader
local M = {}

---@type LzlPlugin[]
M.loading = {}
M.init_done = false
---@type table<string,true>
M.disabled_rtp_plugins = { packer_compiled = true }
---@type table<string,string>
M.did_ftdetect = {}
M.did_handlers = false

function M.setup()
    vim.api.nvim_create_autocmd("ColorSchemePre", {
        callback = function(event)
            M.colorscheme(event.match)
        end,
    })

    -- load the plugins
    Plugin.load()
    Handler.init()

    Config.spec:report()
    Handler.setup()
    M.did_handlers = true
end

---@class Loader
---@param plugins string|LzlPlugin|string[]|LzlPlugin[]
---@param reason {[string]:string}
---@param opts? {force:boolean}
function M.load(plugins, reason, opts)
    plugins = (type(plugins) == "string" or plugins.name) and { plugins } or plugins
    ---@cast plugins (string|LzlPlugin)[]

    for _, plugin in pairs(plugins) do
        if type(plugin) == "string" then
            if Config.active_plugins[plugin] then
                plugin = Config.active_plugins[plugin]
            else
                Util.error("Plugin" .. plugin .. "not found")
                ---@diagnostic disable-next-line: cast-local-type
                plugin = nil
            end
        end
        if plugin and not plugin._.loaded then
            M._load(plugin, reason, opts)
        end
    end
end

function M.colorscheme(name)
    if vim.tbl_contains(vim.fn.getcompletion("", "color"), name) then
        return
    end
    for _, plugin in pairs(Config.active_plugins) do
        if not plugin._.loaded then
            for _, ext in ipairs({ "lua", "vim" }) do
                local path = plugin.dir .. "/colors/" .. name .. "." .. ext
                ---@diagnostic disable-next-line: undefined-field
                if vim.uv.fs_stat(path) then
                    return M.load(plugin, { colorscheme = name })
                end
            end
        end
    end
end
---@param plugin LzlPlugin
---@param reason {[string]:string}
---@param opts? {force:boolean} when force is true, we skip the cond check
function M._load(plugin, reason, opts)
    if not plugin._.installed then
        return Util.error("Plugin " .. plugin.name .. " is not installed\n Dir: " .. plugin.dir)
    end

    if plugin._.cond == false and not (opts and opts.force) then
        return
    end

    if not Handler.did_setup then
        Util.try(function()
            Handler.enable(plugin)
        end, "Failed to setup handlers for " .. plugin.name)
    end

    ---@diagnostic disable-next-line: assign-type-mismatch
    plugin._.loaded = {}
    for k, v in pairs(reason) do
        plugin._.loaded[k] = v
    end
    if #M.loading > 0 then
        plugin._.loaded.plugin = M.loading[#M.loading].name
    elseif reason.require then
        plugin._.loaded.source = Util.get_source()
    end

    table.insert(M.loading, plugin)

    Util.track({ plugin = plugin.name, start = reason.start })
    Handler.disable(plugin)

    M.add_to_rtp(plugin)

    -- if plugin._.pkg and plugin._.pkg.source == "rockspec" then
    --   M.add_to_luapath(plugin)
    -- end

    if plugin.dependencies then
        Util.try(function()
            M.load(plugin.dependencies, {})
        end, "Failed to load deps for " .. plugin.name)
    end

    M.packadd(plugin.dir)
    if plugin.after or plugin.opts then
        M.after(plugin)
    end

    plugin._.loaded.time = Util.track().time
    table.remove(M.loading)
    vim.schedule(function()
        vim.api.nvim_exec_autocmds("User", { pattern = "LazyLoad", modeline = false, data = plugin.name })
        vim.api.nvim_exec_autocmds("User", { pattern = "LazyRender", modeline = false })
    end)
end

--- runs plugin config
---@param plugin LzlPlugin
function M.after(plugin)
    local fn
    if type(plugin.after) == "function" then
        fn = function()
            local opts = Plugin.values(plugin, "opts", false)
            plugin.after(plugin, opts)
        end
    else
        local main = M.get_main(plugin)
        if main then
            fn = function()
                local opts = Plugin.values(plugin, "opts", false)
                require(main).setup(opts)
            end
        else
            return Util.error(
                "Lua module not found for config of " .. plugin.name .. ". Please use a `config()` function instead"
            )
        end
    end
    Util.try(fn, "Failed to run `config` for " .. plugin.name)
end

---@param plugin LzlPlugin
---@return string?
function M.get_main(plugin)
    -- return plugin.name
    if plugin.main then
        return plugin.main
    end
    if plugin.name ~= "mini.nvim" and plugin.name:match("^mini%..*$") then
        return plugin.name
    end
    local normname = Util.normname(plugin.name)
    ---@type string[]
    local mods = {}
    for _, mod in ipairs(Cache.find("*", { all = true, rtp = false, paths = { plugin.dir } })) do
        local modname = mod.modname
        mods[#mods + 1] = modname
        local modnorm = Util.normname(modname)
        -- if we found an exact match, then use that
        if modnorm == normname then
            mods = { modname }
            break
        end
    end

    return #mods == 1 and mods[1] or nil
end

---@param path string
function M.packadd(path)
    M.source_runtime(path, "plugin")
    M.ftdetect(path)
    if M.init_done then
        M.source_runtime(path, "after/plugin")
    end
end

---@param path string
function M.ftdetect(path)
    if not M.did_ftdetect[path] then
        M.did_ftdetect[path] = path
        vim.cmd("augroup filetypedetect")
        M.source_runtime(path, "ftdetect")
        vim.cmd("augroup END")
    end
end

---@param ... string
function M.source_runtime(...)
    local dir = table.concat({ ... }, "/")
    ---@type string[]
    local files = {}
    Util.walk(dir, function(path, name, t)
        local ext = name:sub(-3)
        name = name:sub(1, -5)
        if (t == "file" or t == "link") and (ext == "lua" or ext == "vim") and not M.disabled_rtp_plugins[name] then
            files[#files + 1] = path
        end
    end)
    -- plugin files are sourced alphabetically per directory
    table.sort(files)
    for _, path in ipairs(files) do
        M.source(path)
    end
end

---@param plugin LzlPlugin
function M.add_to_rtp(plugin)
    local rtp = vim.api.nvim_get_runtime_file("", true)
    local idx_dir, idx_after

    for i, path in ipairs(rtp) do
        if path == Config.me then
            idx_dir = i + 1
        elseif not idx_after and path:sub(-6, -1) == "/after" then
            idx_after = i + 1 -- +1 to offset the insert of the plugin dir
            idx_dir = idx_dir or i
            break
        end
    end

    table.insert(rtp, idx_dir or (#rtp + 1), plugin.dir)

    local after = plugin.dir .. "/after"

    ---@diagnostic disable-next-line: undefined-field
    if vim.uv.fs_stat(after) then
        table.insert(rtp, idx_after or (#rtp + 1), after)
    end

    ---@type vim.Option
    vim.opt.rtp = rtp
end

---@param plugin LzlPlugin
function M.deactivate(plugin)
    if not plugin._.loaded then
        return
    end

    local main = M.get_main(plugin)

    if main then
        Util.try(function()
            local mod = require(main)
            if mod.deactivate then
                mod.deactivate(plugin)
            end
        end, "Failed to deactivate plugin " .. plugin.name)
    end

    -- execute deactivate when needed
    if plugin.deactivate then
        Util.try(function()
            plugin.deactivate(plugin)
        end, "Failed to deactivate plugin " .. plugin.name)
    end

    -- disable handlers
    Handler.disable(plugin)

    -- clear plugin properties cache
    plugin._.cache = nil

    -- remove loaded lua modules
    Util.walkmods(plugin.dir .. "/lua", function(modname)
        package.loaded[modname] = nil
        package.preload[modname] = nil
    end)

    -- clear vim.g.loaded_ for plugins
    Util.ls(plugin.dir .. "/plugin", function(_, name, type)
        if type == "file" then
            vim.g["loaded_" .. name:gsub("%..*", "")] = nil
        end
    end)
    -- set as not loaded
    plugin._.loaded = nil
end

---@param path string
function M.source(path)
    Util.track({ runtime = path })
    Util.try(function()
        vim.cmd("source " .. path)
    end, "Failed to source `" .. path .. "`")
    Util.track()
end

---@param plugin LzlPlugin|string
function M.reload(plugin)
    if type(plugin) == "string" then
        plugin = Config.active_plugins[plugin]
    end

    if not plugin then
        error("Plugin not found")
    end

    local load = plugin._.loaded ~= nil
    M.deactivate(plugin)

    -- enable handlers
    Handler.enable(plugin)

    -- run init
    if plugin.init then
        Util.try(function()
            plugin.init(plugin)
        end, "Failed to run `init` for **" .. plugin.name .. "**")
    end

    -- if this is a start plugin, load it now
    if plugin.lazy == false then
        load = true
    end

    local events = plugin._.handlers and plugin._.handlers.event and plugin._.handlers.event or {}

    for _, event in pairs(events) do
        if event.id:find("VimEnter") or event.id:find("UIEnter") or event.id:find("VeryLazy") then
            load = true
            break
        end
    end

    -- reload any vimscript files for this plugin
    local scripts = vim.fn.getscriptinfo()
    local loaded_scripts = {}
    for _, s in ipairs(scripts) do
        ---@type string
        local path = s.name
        if
            path:sub(-4) == ".vim"
            and path:find(plugin.dir, 1, true) == 1
            and not path:find("/plugin/", 1, true)
            and not path:find("/ftplugin/", 1, true)
        then
            loaded_scripts[#loaded_scripts + 1] = path
        end
    end

    if load then
        M.load(plugin, { start = "reload" })
        for _, s in ipairs(loaded_scripts) do
            M.source(s)
        end
    end
end

---@param modname string
function M.loader(modname)
    local paths, cached = Util.get_unloaded_rtp(modname, { cache = true })
    local ret = Cache.find(modname, { rtp = false, paths = paths })[1]

    if not ret and cached then
        paths = Util.get_unloaded_rtp(modname)
        ret = Cache.find(modname, { rtp = false, paths = paths })[1]
    end

    if ret then
        -- explicitly set to nil to prevent loading errors
        package.loaded[modname] = nil
        M.auto_load(modname, ret.modpath)
        local mod = package.loaded[modname]
        if type(mod) == "table" then
            return function()
                return mod
            end
        end
        ---@diagnostic disable-next-line: redundant-parameter
        return loadfile(ret.modpath, nil, nil, ret.stat)
    end
end

function M.startup()
    Util.track({ start = "startup" })

    -- load filetype.lua first since plugins might depend on that
    M.source(vim.env.VIMRUNTIME .. "/filetype.lua")

    -- backup original rtp
    local rtp = vim.opt.rtp:get() --[[@as string[] ]]

    -- 1. run plugin init
    Util.track({ start = "init" })
    for _, plugin in pairs(Config.active_plugins) do
        if plugin.init then
            Util.track({ plugin = plugin.name, init = "init" })
            Util.try(function()
                plugin.init(plugin)
            end, "Failed to run `init` for **" .. plugin.name .. "**")
            Util.track()
        end
    end
    Util.track()

    -- 2. load start plugin
    Util.track({ start = "start" })
    for _, plugin in ipairs(M.get_start_plugins()) do
        -- plugin may be loaded by another plugin in the meantime
        if not plugin._.loaded then
            M.load(plugin, { start = "start" })
        end
    end
    Util.track()

    -- 3. load plugins from the original rtp, excluding after
    Util.track({ start = "rtp plugins" })
    for _, path in ipairs(rtp) do
        if not path:find("after/?$") then
            -- these paths don't will already have their ftdetect ran,
            -- by sourcing filetype.lua above, so skip them
            M.did_ftdetect[path] = path
            M.packadd(path)
        end
    end
    Util.track()

    -- 4. load after plugins
    Util.track({ start = "after" })
    for _, path in
        ipairs(vim.opt.rtp:get() --[[@as string[] ]])
    do
        if path:find("after/?$") then
            M.source_runtime(path, "plugin")
        end
    end
    Util.track()

    M.init_done = true

    Util.track()
end

local DEFAULT_PRIORITY = 50
function M.get_start_plugins()
    ---@type LzlPlugin[]
    local start = {}
    for _, plugin in pairs(Config.active_plugins) do
        if not plugin._.loaded and (plugin._.rtp_loaded or plugin.lazy == false) then
            start[#start + 1] = plugin
        end
    end
    table.sort(start, function(a, b)
        local ap = a.priority or DEFAULT_PRIORITY
        local bp = b.priority or DEFAULT_PRIORITY
        return ap > bp
    end)
    return start
end

function M.auto_load(modname, modpath)
    local plugin = Plugin.find(modpath, { fast = not M.did_handlers })
    if plugin then
        plugin._.rtp_loaded = true
        -- don't load if:
        -- * handlers haven't been setup yet
        -- * we're loading specs
        -- * the plugin is already loaded
        if M.did_handlers and not (Plugin.loading or plugin._.loaded) then
            -- if plugin.module == false then
            --     error("Plugin " .. plugin.name .. " is not loaded and is configured with module=false")
            -- end
            M.load(plugin, { require = modname })
            if plugin._.cond == false then
                error("You're trying to load `" .. plugin.name .. "` for which `cond==false`")
            end
        end
    end
end

return M

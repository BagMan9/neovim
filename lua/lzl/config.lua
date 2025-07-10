local Util = require("lzl.util")
---@class LzlConfig
---@field spec? LzlSpecLoader
---@field p_specs? LzlEndUserData
---@field active_plugins? table<string,LzlPlugin>
---@field options LzlConfigOptions
local M = {}

local base = vim.fn.getenv("HOME") .. "/.local/share/lzl"
---@class LzlConfigOptions
---@field use_attr? string
M.defaults = {
    debug = false,

    use_attr = nil,

    root = base,

    plugin_root = base .. "/mnw-plugins",
    lua_root = base .. "/lua_plugins",

    spec = nil,
}

M.p_specs = nil

M.options = nil

---@param opts? LzlConfigOptions
function M.setup(opts)
    M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})

    M.options.root = Util.norm(M.options.root)
    M.options.plugin_root = Util.norm(M.options.plugin_root)

    vim.fn.mkdir(M.options.root, "p")

    vim.go.packpath = vim.env.VIMRUNTIME

    M.me = debug.getinfo(1, "S").source:sub(2)
    M.me = Util.norm(vim.fn.fnamemodify(M.me, ":p:h:h"))
    local lib = vim.fn.fnamemodify(vim.v.progpath, ":p:h:h") .. "/lib"
    ---@diagnostic disable-next-line: undefined-field
    lib = vim.uv.fs_stat(lib .. "64") and (lib .. "64") or lib
    lib = lib .. "/nvim"

    ---@type vim.Option
    -- vim.opt.rtp = {
    --     --NOTE: Make cleaner?
    --     vim.fn.getenv("HOME") .. "/.config/nvim",
    --     -- vim.fn.stdpath("config"),
    --     vim.fn.stdpath("data") .. "/site",
    --     M.me,
    --     vim.env.VIMRUNTIME,
    --     lib,
    --     vim.fn.stdpath("config") .. "/after",
    -- }

    vim.go.loadplugins = false

    M.mapleader = vim.g.mapleader
    M.maplocalleader = vim.g.maplocalleader

    --NOTE: Do stats here?

    vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        once = true,
        callback = function()
            -- require("lazy.view.commands").setup()
            -- if M.options.change_detection.enabled then
            --   require("lazy.manage.reloader").enable()
            -- end
            -- if M.options.checker.enabled then
            --   vim.defer_fn(function()
            --     require("lazy.manage.checker").start()
            --   end, 10)
            -- end
            --
            -- -- useful for plugin developers when making changes to a packspec file
            -- vim.api.nvim_create_autocmd("BufWritePost", {
            --   pattern = { "lazy.lua", "pkg.json", "*.rockspec" },
            --   callback = function()
            --     local plugin = require("lazy.core.plugin").find(vim.uv.cwd() .. "/lua/")
            --     if plugin then
            --       require("lazy").pkg({ plugins = { plugin } })
            --     end
            --   end,
            -- })

            vim.api.nvim_create_autocmd({ "VimSuspend", "VimResume" }, {
                callback = function(ev)
                    M.suspended = ev.event == "VimSuspend"
                end,
            })
        end,
    })

    Util.very_lazy()
end

return M

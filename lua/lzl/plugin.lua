local Config = require("lzl.config")
local Meta = require("lzl.meta")
local Util = require("lzl.util")

---@class LzlCorePlugin
local M = {}
M.loading = false

---@class LzlSpecLoader
---@field meta LzlMeta
---@field plugins table<string, LzlPlugin>
---@field disabled table<string, LzlPlugin>
---@field ignore_installed table<string, true>
---@field modules string[]
---@field notifs {msg:string, level:number, file?:string}[]
---@field importing? string
---@field optional? boolean
local Spec = {}
M.Spec = Spec

---@param spec? LzlEndUserData
---@param opts? {optional?:boolean}
function Spec.new(spec, opts)
	local self = setmetatable({}, Spec)
	self.meta = Meta.new(self)
	self.disabled = {}
	self.modules = {}
	self.notifs = {}
	self.ignore_installed = {}
	self.optional = opts and opts.optional
	-- if not (opts and opts.pkg == false) then
	--   self.meta:load_pkgs()
	-- end
	if spec then
		self:parse(spec)
	end
	return self
end

function Spec:parse(spec)
	self:normalize(spec)
	self.meta:resolve()
end

---@param spec LzlEndUserData
function Spec:normalize(spec)
	if type(spec) == "string" then
		self.meta:add({ spec })
	elseif #spec > 1 or Util.is_list(spec) then
		---@cast spec LzlPubSpec[]
		for _, s in ipairs(spec) do
			self:normalize(s)
		end
	elseif spec[1] then
		---@cast spec LzlPubSpec
		self.meta:add(spec)
		---@cast spec LzlImportSpec
		if spec and spec.import then
			self:import(spec)
		end
	elseif spec.import then
		---@cast spec LzlImportSpec
		self:import(spec)
	else
		self:error("Invalid plugin spec " .. vim.inspect(spec))
	end
end

---@param spec LzlImportSpec
function Spec:import(spec)
	---@param modname string
	---@param modpath string
	---@return modspec
	local function ingest_modname(modname, modpath)
		return {
			modname = modname,
			load = function()
				local mod, err = loadfile(modpath)
				if mod then
					return mod()
				else
					return nil, err
				end
			end,
		}
	end
	---@param modname string module name in the format `foo.bar`
	---@return string modpath module path in the format `foo/bar`
	local function mod_name_to_path(modname)
		return vim.fs.joinpath(unpack(vim.split(modname, ".", { plain = true })))
	end

	if spec.import == "lzl" then
		vim.schedule(function()
			vim.notify("Plugins modules cannot be called 'lzl'", vim.log.levels.ERROR)
		end)
		return
	end
	if type(spec.import) ~= "string" then
		vim.schedule(function()
			vim.notify(
				"Invalid import spec. The 'import' field should be a module name: " .. vim.inspect(spec),
				vim.log.levels.ERROR
			)
		end)
		return
	end
	if spec.enabled == false or (type(spec.enabled) == "function" and not spec.enabled()) then
		return
	end
	---@alias modspec {modname: string, load:fun():(LzlPubSpec?,string?)}
	---@type modspec[]

	local import_name = spec.import
	local imported = 0
	local modspecs = {}
	local import = spec.import
	if type(import) == "string" then
		Util.lsmod(import, function(modname, modpath)
			modspecs[#modspecs + 1] = {
				modname = modname,
				load = function()
					local mod, err = loadfile(modpath)
					if mod then
						return mod()
					else
						return nil, err
					end
				end,
			}
		end)
		table.sort(modspecs, function(a, b)
			return a.modname < b.modname
		end)
	else
		modspecs = { { modname = import_name, load = spec.import } }
	end

	for _, modspec in ipairs(modspecs) do
		imported = imported + 1
		local modname = modspec.modname
		Util.track({ import = modname })
		self.importing = modname
		-- unload the module so we get a clean slate
		---@diagnostic disable-next-line: no-unknown
		package.loaded[modname] = nil
		Util.try(function()
			local mod, err = modspec.load()
			if err then
				self:error("Failed to load `" .. modname .. "`:\n" .. err)
			elseif type(mod) ~= "table" then
				return self:error(
					"Invalid spec module: `"
						.. modname
						.. "`\nExpected a `table` of specs, but a `"
						.. type(mod)
						.. "` was returned instead"
				)
			else
				mod = mod.lz_specs or mod
				self:normalize(mod)
			end
		end, {
			msg = "Failed to load `" .. modname .. "`",
			on_error = function(msg)
				self:error(msg)
			end,
		})
		self.importing = nil
		Util.track()
	end
	if imported == 0 then
		self:error("No specs found for module " .. vim.inspect(spec.import))
	end
end
function Spec:error(msg)
	self:log(msg, vim.log.levels.ERROR)
end

function Spec:warn(msg)
	self:log(msg, vim.log.levels.WARN)
end

---@param msg string
---@param level number
function Spec:log(msg, level)
	self.notifs[#self.notifs + 1] = { msg = msg, level = level, file = self.importing }
end

function Spec:report(level)
	level = level or vim.log.levels.ERROR
	local count = 0
	for _, notif in ipairs(self.notifs) do
		if notif.level >= level then
			Util.notify(notif.msg, { level = notif.level })
			count = count + 1
		end
	end
	return count
end

function Spec:__index(key)
	if Spec[key] then
		return Spec[key]
	end
	if key == "plugins" then
		self.meta:rebuild()
		return self.meta.plugins
	end
end

function M.load()
	M.loading = true
	Config.spec = Spec.new()

	local specs = {
		vim.deepcopy(Config.options.spec),
	}

	Config.spec:parse(specs)

	-- Handle reloads
	local existing = Config.active_plugins
	Config.active_plugins = Config.spec.plugins
	for name, plugin in pairs(existing or {}) do
		if Config.active_plugins[name] then
			local new_state = Config.active_plugins[name]._
			Config.active_plugins[name]._ = plugin._
			Config.active_plugins[name]._.dep = new_state.dep
			Config.active_plugins[name]._.frags = new_state.frags
			-- Config.active_plugins[name]._.pkg = new_state.pkg
		end
	end

	M.update_state()

	M.loading = false
end

function M.update_state()
	local installed = {}
	Util.ls(Config.options.plugin_root, function(_, name, type)
		if type == "directory" and name ~= "readme" then
			installed[name] = type
		end
	end)

	local lua_installed = {}
	Util.ls(Config.options.lua_root, function(_, name, type)
		if type == "directory" and name ~= "readme" then
			lua_installed[name] = type
		end
	end)
	-- Util.notify(vim.inspect(lua_installed))

	for _, plugin in pairs(Config.active_plugins) do
		-- Util.notify(vim.inspect(plugin))
		plugin._ = plugin._ or {}
		if plugin.lazy == nil then
			local lazy = plugin._.dep or true or plugin.event or plugin.keys or plugin.ft or plugin.cmd
			plugin.lazy = lazy and true or false
		end
		--NOTE: This may break stuff later
		if installed[plugin.name] ~= nil then
			plugin._.installed = installed[plugin.name] ~= nil
			installed[plugin.name] = nil
		elseif lua_installed[plugin.name] ~= nil then
			plugin._.installed = true
			lua_installed[plugin.name] = nil
			plugin.dir = Config.options.lua_root .. "/" .. plugin.name
		else
		end
	end
end

---@param plugin LzlPlugin
---@param prop string
---@param is_list? boolean
function M.values(plugin, prop, is_list)
	if not plugin[prop] then
		return {}
	end
	plugin._.cache = plugin._.cache or {}
	local key = prop .. (is_list and "_list" or "")
	if plugin._.cache[key] == nil then
		plugin._.cache[key] = M._values(plugin, plugin, prop, is_list)
	end
	return plugin._.cache[key]
end

---@param root LzlPlugin
---@param plugin LzlPlugin
---@param prop string
---@param is_list? boolean
function M._values(root, plugin, prop, is_list)
	if not plugin[prop] then
		return {}
	end
	local super = getmetatable(plugin)
	---@type table
	local ret = super and M._values(root, super.__index, prop, is_list) or {}
	local values = rawget(plugin, prop)

	if not values then
		return ret
	elseif type(values) == "function" then
		ret = values(root, ret) or ret
		return type(ret) == "table" and ret or { ret }
	end

	values = type(values) == "table" and values or { values }
	if is_list then
		return Util.extend(ret, values)
	else
		---@type {path:string[], list:any[]}[]
		local lists = {}
		---@diagnostic disable-next-line: no-unknown
		for _, key in ipairs(plugin[prop .. "_extend"] or {}) do
			local path = vim.split(key, ".", { plain = true })
			local r = Util.key_get(ret, path)
			local v = Util.key_get(values, path)
			if type(r) == "table" and type(v) == "table" then
				lists[key] = { path = path, list = {} }
				vim.list_extend(lists[key].list, r)
				vim.list_extend(lists[key].list, v)
			end
		end
		local t = Util.merge(ret, values)
		for _, list in pairs(lists) do
			Util.key_set(t, list.path, list.list)
		end
		return t
	end
end

-- Finds the plugin that has this path
---@param path string
---@param opts? {fast?:boolean}
function M.find(path, opts)
	if not Config.spec then
		return
	end
	opts = opts or {}
	local lua = path:find("/lua/", 1, true)
	if lua then
		local name = path:sub(1, lua - 1)
		local slash = name:reverse():find("/", 1, true)
		if slash then
			name = name:sub(#name - slash + 2)
			if name then
				if opts.fast then
					return Config.spec.meta.plugins[name]
				end
				return Config.spec.plugins[name]
			end
		end
	end
end

return M

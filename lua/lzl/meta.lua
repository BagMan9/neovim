local Config = require("lzl.config")
local Util = require("lzl.util")
--NOTE: Make type
--
---@class LzlMeta
---@field spec LzlSpecLoader
---@field fragments LzlFragments
---@field str_to_meta table<string,LzlPlugin>
---@field frag_to_meta table<integer,LzlPlugin>
---@field dirty table<string,boolean>
---@field plugins table<string,LzlPlugin>
local M = {}

---@param spec LzlSpecLoader
---@return LzlMeta
function M.new(spec)
	local self = setmetatable({}, { __index = M })
	self.spec = spec
	self.fragments = require("lzl.fragments").new(spec)
	self.plugins = {}
	self.frag_to_meta = {}
	self.str_to_meta = {}
	self.dirty = {}
	return self
end

--@param plugin lz.n.PluginSpec
--May be fix? Types getting weird
--
---@param plugin LzlPubSpec
function M:add(plugin)
	local fragment = self.fragments:add(plugin)

	if not fragment then
		return
	end

	local data = self.plugins[fragment.name]

	if not data then
		data = { name = fragment.name, _ = { frags = {} } }
	end

	table.insert(data._.frags, fragment.id)

	self.plugins[data.name] = data
	self.frag_to_meta[fragment.id] = data
	self.dirty[data.name] = true
	return data, fragment
end

---@param name string
function M:del(name)
	local data = self.plugins[name]
	if not data then
		return
	end
	for _, fid in ipairs(data._.frags or {}) do
		self.fragments:del(fid)
	end
	self.plugins[name] = nil
end

function M:resolve()
	self:rebuild()

	--MORE STUFF?
end

function M:rebuild()
	local frag_count = vim.tbl_count(self.fragments.dirty)
	local plugin_count = vim.tbl_count(self.dirty)
	if frag_count == 0 and plugin_count == 0 then
		return
	end
	-- if Config.options.debug then
	--   Util.track("rebuild plugins frags=" .. frag_count .. " plugins=" .. plugin_count)
	-- end
	for fid in pairs(self.fragments.dirty) do
		local meta = self.frag_to_meta[fid]
		if meta then
			if self.fragments:get(fid) then
				-- fragment still exists, so mark plugin as dirty
				self.dirty[meta.name] = true
			else
				-- fragment was deleted, so remove it from plugin
				self.frag_to_meta[fid] = nil
				---@param f number
				meta._.frags = Util.filter(function(f)
					return f ~= fid
				end, meta._.frags)
				-- if no fragments left, delete plugin
				if #meta._.frags == 0 then
					self:del(meta.name)
				else
					self.dirty[meta.name] = true
				end
			end
		end
	end
	self.fragments.dirty = {}
	for n, _ in pairs(self.dirty) do
		self:_rebuild(n)
	end
	-- if Config.options.debug then
	--   Util.track()
	-- end
end

---@param name string
function M:_rebuild(name)
	if not self.dirty[name] then
		return
	end
	self.dirty[name] = nil
	local plugin = self.plugins[name]
	if not plugin or #plugin._.frags == 0 then
		self.plugins[name] = nil
		return
	end
	setmetatable(plugin, nil)
	plugin.dependencies = {}

	local super = nil
	-- plugin.url = nil
	plugin._.dep = true
	plugin._.top = true

	assert(#plugin._.frags > 0, "no fragments found for plugin " .. name)

	---@type table<number, boolean>
	local added = {}
	for _, fid in ipairs(plugin._.frags) do
		if not added[fid] then
			added[fid] = true
			local fragment = self.fragments:get(fid)
			assert(fragment, "fragment " .. fid .. " not found, for plugin " .. name)
			---@diagnostic disable-next-line: no-unknown
			super = setmetatable(fragment.spec, super and { __index = super } or nil)
			plugin._.dep = plugin._.dep and fragment.dep
			-- plugin.url = fragment.url or plugin.url
			plugin._.top = plugin._.top and fragment.pid == nil

			-- dependencies
			for _, dep in ipairs(fragment.deps or {}) do
				local dep_meta = self.frag_to_meta[dep]
				if dep_meta then
					table.insert(plugin.dependencies, dep_meta.name)
				end
			end
		end
	end

	super = super or {}

	-- plugin.dir = super.dir
	-- if plugin.dir then
	--     plugin.dir = Util.norm(plugin.dir)

	plugin.dir = plugin.dir
		or (plugin.lua and Config.options.lua_root or Config.options.plugin_root) .. "/" .. plugin.name
	--

	-- dependencies
	if #plugin.dependencies == 0 and not super.dependencies then
		plugin.dependencies = nil
	end

	setmetatable(plugin, { __index = super })

	return plugin
end

return M

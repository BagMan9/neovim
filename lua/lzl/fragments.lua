local Config = require("lzl.config")
local Util = require("lzl.util")

---@class LzlFragments
---@field fragments table<integer, LzlFragment>
---@field frag_stack integer[]
---@field dep_stack integer[]
---@field dirty table<number, boolean>
---@field plugins table<LzlPlugin, integer>
---@field spec LzlSpecLoader
local M = {}

-- Keep track of current unique fragment id
M._fid = 0

---@return integer
local function next_id()
    M._fid = M._fid + 1
    return M._fid
end

---@param spec LzlSpecLoader
---@return LzlFragments
function M.new(spec)
    local self = setmetatable({}, { __index = M })
    self.fragments = {}
    self.frag_stack = {}
    self.dep_stack = {}
    self.spec = spec
    self.dirty = {}
    self.plugins = {}
    return self
end

---@param id integer
---@return LzlFragment?
function M:get(id)
    return self.fragments[id]
end

---@param id integer
function M:del(id)
    local fragment = self.fragments[id]
    if not fragment then
        return
    end

    self.dirty[id] = true

    -- remove from parent
    local pid = fragment.pid
    if pid then
        local parent = self.fragments[pid]
        if parent.frags then
            ---@param fid number
            parent.frags = Util.filter(function(fid)
                return fid ~= id
            end, parent.frags)
        end
        if parent.deps then
            ---@param fid number
            parent.deps = Util.filter(function(fid)
                return fid ~= id
            end, parent.deps)
        end
        self.dirty[pid] = true
    end

    -- remove children
    if fragment.frags then
        for _, fid in ipairs(fragment.frags) do
            self:del(fid)
        end
    end

    self.fragments[id] = nil
end

---@param plugin LzlPubSpec
function M:add(plugin)
    -- If I've seen this fragment, return it.
    if self.plugins[plugin] then
        return self.fragments[self.plugins[plugin]]
    end

    local id = next_id()
    setmetatable(plugin, nil)
    self.plugins[plugin] = id

    local pid = self.frag_stack[#self.frag_stack]

    ---@type LzlFragment
    local fragment = {
        id = id,
        pid = pid,
        name = plugin.name,
        spec = plugin,
    }

    -- Plugin always has directory based name, no slash or url to deal with
    fragment.name = fragment.name or plugin[1]

    if not fragment.name or fragment.name == "" then
        return self.spec:error("Invalid plugin spec " .. vim.inspect(plugin))
    end

    self.fragments[id] = fragment

    if pid then
        local parent = self.fragments[pid]
        parent.frags = parent.frags or {}
        table.insert(parent.frags, id)
    end

    -- Make sure parent dependencies are part of plugin (I don't care about supporting)
    local did = self.dep_stack[#self.dep_stack]
    if did and did == pid then
        fragment.dep = true
        local parent = self.fragments[did]
        parent.deps = parent.deps or {}
        table.insert(parent.deps, id)
    end

    table.insert(self.frag_stack, id)
    -- dependencies
    if plugin.dependencies then
        table.insert(self.dep_stack, id)
        self.spec:normalize(plugin.dependencies)
        table.remove(self.dep_stack)
    end

    table.remove(self.frag_stack)

    return fragment
end

return M

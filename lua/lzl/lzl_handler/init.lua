local Config = require("lzl.config")
local Util = require("lzl.util")

---@class LzlHandler
---@field type LzlHandlerTypes
---@field extends? LzlHandler
---@field active table<string,table<string,string>>
---@field managed table<string,string> mapping handler keys to plugin names
---@field super LzlHandler
local M = {}

---@enum LzlHandlerTypes
M.types = {
    keys = "keys",
    event = "event",
    cmd = "cmd",
    ft = "ft",
}

---@type table<string,LzlHandler>
M.handlers = {}

M.did_setup = false

function M.init()
    for _, type in pairs(M.types) do
        M.handlers[type] = M.new(type)
    end
end

function M.setup()
    M.did_setup = true
    for _, plugin in pairs(Config.active_plugins) do
        Util.try(function()
            M.enable(plugin)
        end, "Failed to setup handlers for " .. plugin.name)
    end
end

---@param plugin LzlPlugin
function M.disable(plugin)
    for type in pairs(plugin._.handlers or {}) do
        M.handlers[type]:del(plugin)
    end
end

---@param plugin LzlPlugin
function M.enable(plugin)
    if not plugin._.loaded then
        if not plugin._.handlers then
            M.resolve(plugin)
        end
        for type in pairs(plugin._.handlers or {}) do
            M.handlers[type]:add(plugin)
        end
    end
end

---@param _value string
---@protected
function M:_add(_value) end

---@param _value string
---@protected
function M:_del(_value) end

---@param value any
---@param _plugin LazyPlugin
---@return string|{id:string}
function M:_parse(value, _plugin)
    assert(type(value) == "string", "Expected string, got " .. vim.inspect(value))
    return value
end

---@param type LzlHandlerTypes
function M.new(type)
    ---@type LzlHandler
    local handler = require("lzl.lzl_handler." .. type)
    local super = handler.extends or M
    local self = setmetatable({}, { __index = setmetatable(handler, { __index = super }) })
    self.super = super
    self.active = {}
    self.managed = {}
    self.type = type
    return self
end

---@param values any[]
---@param plugin LzlPlugin
function M:_values(values, plugin)
    ---@type table<string,any>
    local ret = {}
    for _, value in ipairs(values) do
        local parsed = self:_parse(value, plugin)
        ret[type(parsed) == "string" and parsed or parsed.id] = parsed
    end
    return ret
end

---@param plugin LzlPlugin
function M.resolve(plugin)
    local Plugin = require("lzl.plugin")
    plugin._.handlers = {}
    for type, handler in pairs(M.handlers) do
        if plugin[type] then
            plugin._.handlers[type] = handler:_values(Plugin.values(plugin, type, true), plugin)
        end
    end
end

---@param plugin LzlPlugin
function M:add(plugin)
    for key, value in pairs(plugin._.handlers[self.type] or {}) do
        if not self.active[key] then
            self.active[key] = {}
            self:_add(value)
            self.managed[key] = plugin.name
        end
        self.active[key][plugin.name] = plugin.name
    end
end

---@param plugin LzlPlugin
function M:del(plugin)
    if not plugin._.handlers then
        return
    end
    for key, value in pairs(plugin._.handlers[self.type] or {}) do
        if self.active[key] and self.active[key][plugin.name] then
            self.active[key][plugin.name] = nil
            if vim.tbl_isempty(self.active[key]) then
                self:_del(value)
                self.active[key] = nil
            end
        end
    end
end
return M

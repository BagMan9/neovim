local Event = require("lzl.lzl_handler.event")
local Loader = require("lzl.lzl_loader")

---@class LzlFiletypeHandler:LzlEventHandler
local M = {}
M.extends = Event

---@param plugin LzlPlugin
function M:add(plugin)
    self.super.add(self, plugin)
    if plugin.ft then
        Loader.ftdetect(plugin.dir)
    end
end

---@return LzlEvent
function M:_parse(value)
    return {
        id = value,
        event = "FileType",
        pattern = value,
    }
end

return M

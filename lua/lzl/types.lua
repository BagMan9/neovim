---@mod LzlTypes

---
---@class LzlFragment
---@field id integer
---@field pid? integer
---@field deps? number[]
---@field frags? number[]
---@field dep? boolean
---@field name string
---@field spec LzlPubSpec

---@class LzlManageData
---@field cache? table<string,any>
---@field frags? number[]
---@field dep? boolean
---@field top? boolean
---@field loaded? {[string]:string}|{time:number}
---@field handlers? table<string,LzlHandler>
---@field cond? boolean
---@field installed? boolean
---@field rtp_loaded? boolean

---@class LzlPubHandlers
---@field event? string|LzlEventSpec[]
---@field keys? LzlKeysSpec[]
---@field cmd? string[]|string
---@field colorscheme? string[]|string
---@field lazy? boolean
---@field ft? string[]|string
---
---@class LzlPrivHandlers
---@field event? LzlEventSpec[]
---@field keys? LzlKeysSpec[]
---@field cmd? string[]
---@field colorscheme? string[]
---@field lazy? boolean
---@field ft? string[]
---
---@class LzlAttrs
---@field lua? boolean
---@field priority? number
---@field opts? table|fun():table
---@field dependencies? LzlPubSpec[]
---@field enabled? boolean|fun():boolean
---@field dir? string Manually specify location
---
---@class LzlHooks
---@field init? fun(self:LzlPlugin) Will be run before loading any plugins
---@field before? fun(self:LzlPlugin) Will be run before loading this plugin
---@field after? fun(self:LzlPlugin,opts:table) Will be executed after loading this plugin

---@class LzlPubSpec: LzlPubHandlers,LzlHooks, LzlAttrs
---@field [1] string
---@field name? string
---
---
---
---@class LzlPlugin: LzlAttrs,LzlHooks,LzlPrivHandlers
---@field name string
---@field dir? string
---@field _ LzlManageData
---@field deactivate? fun(p:LzlPlugin)

---@class LzlImportSpec
---@field import string
---@field enabled? boolean|fun():boolean

---@alias LzlEndUserData LzlImportSpec|LzlImportSpec[]|LzlPubSpec|LzlPubSpec[]

error("Cannot import a meta module")

local M = {}
return M

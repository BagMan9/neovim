---@meta

-- My stuff

---@class PrePluginSpec
---@field opts? table
---@field cmd? string|string[]
---@field event? string|string[]
---@field keys? lz.n.KeysSpec[]
---@field ft? string|string[]
---@field colorscheme? string|string[]
---@field before? fun()
---@field setup? fun(opts?:table)|false
---@field req? string
---@field needs? string|string[]
---@field enabled? boolean
---@field priority? number
---@field lazy? boolean
---
-- Lz.n Stuff
---@class lz.n.PluginBase
---
--- Whether to enable this plugin. Useful to disable plugins under certain conditions.
---@field enabled? boolean|(fun():boolean)
---
--- Only useful for lazy=false plugins to force loading certain plugins first.
--- Default priority is 50
---@field priority? number
---
--- Set this to override the `load` function for an individual plugin.
--- Defaults to `vim.g.lz_n.load()`, see |lz.n.Config|.
---@field load? fun(name: string)

---@alias lz.n.Event {id:string, event:string[]|string, pattern?:string[]|string}
---@alias lz.n.EventSpec string|{event?:string|string[], pattern?:string|string[]}|string[]

---@class lz.n.PluginHooks
---@field beforeAll? fun(self:lz.n.Plugin) Will be run before loading any plugins
---@field before? fun(self:lz.n.Plugin) Will be run before loading this plugin
---@field after? fun(self:lz.n.Plugin) Will be executed after loading this plugin

---@class lz.n.PluginHandlers
---@field event? lz.n.Event[]
---@field keys? lz.n.Keys[]
---@field cmd? string[]
---@field colorscheme? string[]
---@field lazy? boolean

---@class lz.n.PluginSpecHandlers
---
--- Load a plugin on one or more |autocmd-events|.
---@field event? string|lz.n.EventSpec[]
---
--- Load a plugin on one or more |user-commands|.
---@field cmd? string[]|string
---
--- Load a plugin on one or more |FileType| events.
---@field ft? string[]|string
---
--- Load a plugin on one or more |key-mapping|s.
---@field keys? string|string[]|lz.n.KeysSpec[]
---
--- Load a plugin on one or more |colorscheme| events.
---@field colorscheme? string[]|string
---
--- Lazy-load manually, e.g. using `trigger_load`.
--- Will disable lazy-loading if explicitly set to `false`.
---@field lazy? boolean

---@class lz.n.KeysBase: vim.keymap.set.Opts
---@field desc? string
---@field noremap? boolean
---@field remap? boolean
---@field expr? boolean
---@field nowait? boolean
---@field ft? string|string[]

---@class lz.n.KeysSpec: lz.n.KeysBase
---@field [1] string lhs
---@field [2]? string|fun()|false rhs
---@field mode? string|string[]

---@class lz.n.Keys: lz.n.KeysBase
---@field lhs string lhs
---@field rhs? string|fun() rhs
---@field mode? string
---@field id string
---@field name string

---@class lz.n.Plugin: lz.n.PluginBase,lz.n.PluginHandlers,lz.n.PluginHooks
---
--- The plugin name (not its main module), e.g. "sweetie.nvim"
---@field name string
---
--- Whether to lazy-load this plugin. Defaults to `false`.
---@field lazy? boolean

---@class lz.n.PluginSpec: lz.n.PluginBase,lz.n.PluginSpecHandlers,lz.n.PluginHooks
---
--- The plugin name (not its main module), e.g. "sweetie.nvim"
---@field [1] string

---@class lz.n.SpecImport
---@field import string spec module to import
---@field enabled? boolean|(fun():boolean)

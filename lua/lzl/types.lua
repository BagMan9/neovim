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
---@class LzlSource
---@field type "github"|"gitlab"|"git"
---@field owner? string For github/gitlab
---@field repo string Repository name
---@field url? string For git type
---@field branch? string Optional branch
---@field rev? string Optional revision for pinning

---@class LzlBuildSpec
---@field nvimSkipModules? string[] Modules to skip in nix build
---@field nixDeps? string[] Nix plugin dependencies
---@field useNixpkgs? string Use pkgs.vimPlugins.X instead of building from source

---@class LzlAttrs
---@field lua? boolean
---@field priority? number
---@field opts? table|fun():table
---@field dependencies? LzlPubSpec[]
---@field enabled? boolean|fun():boolean
---@field dir? string Manually specify location
---@field source? LzlSource Plugin source for npins
---@field extraPackages? string[] Runtime executables needed
---@field build? LzlBuildSpec Nix build hints
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

---@class LzlImportSpec
---@field import string
---@field enabled? boolean|fun():boolean

---@alias LzlEndUserData LzlImportSpec|LzlImportSpec[]|LzlPubSpec|LzlPubSpec[]

error("Cannot import a meta module")

local M = {}
return M

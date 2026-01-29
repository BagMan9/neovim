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
---@field export? LzlExportConfig

---@class LzlExportConfig
---@field npins_dir? string Directory where npins sources.json lives
---@field plugins_json? string Path to write plugins.json

M.defaults = {
	debug = false,

	use_attr = nil,

	root = base,

	plugin_root = base .. "/mnw-plugins",
	lua_root = base .. "/lua_plugins",

	spec = nil,

	-- Export configuration for npins integration
	-- TODO: Make platform independent (stdpath doesn't work with mnw wrapper)
	export = {
		npins_dir = "/Users/isaac/.config/nvim",
		plugins_json = "/Users/isaac/.config/nvim/npins/plugins.json",
	},
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

	vim.go.loadplugins = false

	M.mapleader = vim.g.mapleader
	M.maplocalleader = vim.g.maplocalleader

	--NOTE: Do stats here?

	vim.api.nvim_create_autocmd("User", {
		pattern = "VeryLazy",
		once = true,
		callback = function()
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

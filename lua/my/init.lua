_G.Utils = require("my.utils")
-- _G.Lazy = require("lz.n")
-- _G.Plugins = require("plugins")

---@class MyVim
---@field events MyVim.lazyfile
---@field utils MyVim.util
---@field lsp MyVim.intellisense
---@field intellisense MyVim.intellisense
---@field fetcher MyVim.fetcher
local M = {}
setmetatable(M, {
	__index = function(t, k)
		t[k] = require("my." .. k)
		return t[k]
	end,
})

---@return nil
function M.init()
	MyVim.events.init_lazy_file()
	M.pre_setup()
	-- Plugins.create_npins()
	local mnw_pack = mnw.configDir .. "/pack/mnw"
	require("lzl").lzl_setup({
		spec = { import = "plugins" },
		plugin_root = mnw_pack .. "/opt",
		lua_root = mnw_pack .. "/start",
	})
	vim.opt.runtimepath:append(mnw_pack .. "/start/myconf")
	vim.cmd.colorscheme("catppuccin-mocha")
	require("keymaps")
end

---@return nil
function M.pre_setup()
	-- Experimental Loader
	vim.loader.enable()

	require("my.options")

	require("my.autocmds")
end

return M

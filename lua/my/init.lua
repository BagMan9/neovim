_G.Utils = require("my.utils")
_G.Lazy = require("lz.n")
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

	require("lzl").lzl_setup({ spec = { import = "plugins" } })

	vim.cmd.colorscheme("catppuccin")

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

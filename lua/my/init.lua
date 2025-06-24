_G.Utils = require("my.utils")

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
	require("lz.n").load("plugins")
	vim.cmd.colorscheme("catppuccin")

	require("keymaps")
end

function M.pre_setup()
	-- Experimental Loader
	vim.loader.enable()

	require("my.options")

	require("my.autocmds")
end

return M

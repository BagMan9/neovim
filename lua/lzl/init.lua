local M = {}

---Load init lzl
---@param opts? LzlConfigOptions
function M.lzl_setup(opts)
	vim.loader.enable()

	local Config = require("lzl.config")
	local Loader = require("lzl.lzl_loader")

	table.insert(package.loaders, 3, Loader.loader)

	-- Setup export command for npins integration
	require("lzl.export").setup_command()

	Config.setup(opts)
	Loader.setup()
	Loader.startup()

	vim.api.nvim_exec_autocmds("User", { pattern = "LazyDone", modeline = false })
end

return M

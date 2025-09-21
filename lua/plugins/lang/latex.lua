local viewer_open = false
local vimtex_grp = vim.api.nvim_create_augroup("latex", { clear = true })
-- -- TODO: Make Auto focus (use yabai / shell) specific?
---@diagnostic disable-next-line: undefined-field
if vim.uv.os_uname().sysname == "Darwin" then
	vim.api.nvim_create_autocmd("User", {
		pattern = "VimtexEventViewReverse",
		group = vimtex_grp,
		callback = function()
			local on_ex = function(out)
				local json = vim.json.decode(out.stdout)
				for _, win in ipairs(json) do
					if win.app == "kitty" then
						vim.system({ "yabai", "-m", "window", "--focus", win.id })
					end
				end
			end
			vim.system({ "yabai", "-m", "query", "--windows" }, {}, on_ex)
		end,
	})

	vim.api.nvim_create_autocmd("User", {
		pattern = "VimtexEventQuit",
		callback = function()
			-- if viewer_open == false then
			-- 	return
			-- end
			local chans = vim.api.nvim_list_chans()
			for _, st in ipairs(chans) do
				if st.argv and #st.argv >= 3 and st.argv[3]:sub(1, 6) == "sioyek" then
					vim.fn.jobstop(st.id)
					break
				end
			end
		end,
	})
end

return {
	{
		"nvim-lspconfig",
		opts = {
			servers = {
				texlab = {
					keys = {
						{ "<Leader>K", "<plug>(vimtex-doc-package)", desc = "Vimtex Docs", silent = true },
					},
				},
			},
		},
	},
	{
		"nvim-treesitter",
		opts = function(_, opts)
			opts.highlight = opts.highlight or {}
			if type(opts.ensure_installed) == "table" then
				vim.list_extend(opts.ensure_installed, { "bibtex" })
			end
			if type(opts.highlight.disable) == "table" then
				vim.list_extend(opts.highlight.disable, { "latex" })
			else
				opts.highlight.disable = { "latex" }
			end
		end,
	},
	{
		"blink.cmp",
		dependencies = {},
	},
}

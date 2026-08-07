return {
	{
		"indent-blankline.nvim",
		enabled = true,
		source = {
			type = "github",
			repo = "indent-blankline.nvim",
			owner = "lukas-reineke",
		},
		build = {
			nvimSkipModules = {
				"ibl.config.types",
			},
		},
		event = "VeryLazy",
		opts = {
			indent = {
				char = "│",
				tab_char = "│",
			},
			scope = { enabled = false, highlight = { "Function", "Label" } },
			exclude = {
				filetypes = {
					"Trouble",
					"alpha",
					"dashboard",
					"help",
					"lazy",
					"mason",
					"neo-tree",
					"notify",
					"snacks_dashboard",
					"snacks_notif",
					"snacks_terminal",
					"snacks_win",
					"toggleterm",
					"trouble",
				},
			},
		},
		after = function(_, opts)
			local ibl = require("ibl")
			local hooks = require("ibl.hooks")

			-- Define custom highlight groups for diagnostics
			-- hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
			-- 	vim.api.nvim_set_hl(0, "IblScopeError", { fg = "#f38ba8", bold = true })
			-- 	vim.api.nvim_set_hl(0, "IblScopeWarn", { fg = "#f9e2af" })
			-- end)
			--
			-- -- Intercept scope highlight rendering
			-- hooks.register(hooks.type.SCOPE_HIGHLIGHT, function(tick, bufnr, scope)
			-- 	-- Get start and end lines of the current code block / function
			-- 	local start_line = scope:start()
			-- 	local end_line = scope:end_()
			--
			-- 	-- Query Neovim's LSP diagnostics within this line range
			-- 	local diagnostics = vim.diagnostic.get(bufnr, {
			-- 		lnum = { start_line, end_line },
			-- 	})
			--
			-- 	-- Check the highest severity diagnostic inside the scope
			-- 	local has_error = false
			-- 	local has_warn = false
			--
			-- 	for _, d in ipairs(diagnostics) do
			-- 		if d.severity == vim.diagnostic.severity.ERROR then
			-- 			has_error = true
			-- 			break
			-- 		elseif d.severity == vim.diagnostic.severity.WARN then
			-- 			has_warn = true
			-- 		end
			-- 	end
			--
			-- 	-- Return the custom highlight group depending on diagnostic state
			-- 	if has_error then
			-- 		return "IblScopeError"
			-- 	elseif has_warn then
			-- 		return "IblScopeWarn"
			-- 	end
			--
			-- 	-- Return nil to fall back to the default scope highlight group
			-- 	return nil
			-- end)

			ibl.setup(opts)
		end,
	},
	-- {
	-- 	"mini.indentscope",
	-- 	enabled = false,
	-- 	source = {
	-- 		type = "github",
	-- 		repo = "mini.indentscope",
	-- 		owner = "nvim-mini",
	-- 	},
	-- 	event = "VeryLazy",
	-- 	after = function()
	-- 		local opts = {
	-- 			-- symbol = "▏",
	-- 			symbol = "│",
	-- 			options = { try_as_border = true },
	-- 		}
	-- 		require("mini.indentscope").setup(opts)
	-- 	end,
	-- 	init = function()
	-- 		vim.api.nvim_create_autocmd("FileType", {
	-- 			pattern = {
	-- 				"Trouble",
	-- 				"alpha",
	-- 				"dashboard",
	-- 				"fzf",
	-- 				"help",
	-- 				"lazy",
	-- 				"mason",
	-- 				"neo-tree",
	-- 				"notify",
	-- 				"snacks_dashboard",
	-- 				"snacks_notif",
	-- 				"snacks_terminal",
	-- 				"snacks_win",
	-- 				"toggleterm",
	-- 				"trouble",
	-- 			},
	-- 			callback = function()
	-- 				vim.b.miniindentscope_disable = true
	-- 			end,
	-- 		})
	-- 		vim.api.nvim_create_autocmd("User", {
	-- 			pattern = "SnacksDashboardOpened",
	-- 			callback = function(data)
	-- 				vim.b[data.buf].miniindentscope_disable = true
	-- 			end,
	-- 		})
	-- 	end,
	-- },
}

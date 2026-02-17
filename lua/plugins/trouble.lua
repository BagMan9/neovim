local M = {}

M.lz_specs = {
	{
		"trouble.nvim",
		source = {
			type = "github",
			repo = "trouble.nvim",
			owner = "folke",
		},
		build = {
			nvimSkipModules = { "trouble.docs" },
		},
		cmd = { "Trouble" },
		opts = {
			open_no_results = true,
			modes = {
				my_diag = {
					mode = "diagnostics",
					preview = {
						type = "float",
						relative = "editor",
						border = "rounded",
						title = "Preview",
						title_pos = "center",
						position = { 5, -2 },
						size = { width = 0.35, height = 0.25 },
						zindex = 200,
					},
				},
				useful_info = {
					desc = "My global info",
					sections = {
						"lsp_references",
						"lsp_definitions",
						"lsp_implementations",
						"lsp_type_definitions",
						"lsp_declarations",
					},
					preview = {
						type = "float",
						relative = "editor",
						border = "rounded",
						title = "Preview",
						title_pos = "center",
						position = { 5, -2 },
						size = { width = 0.35, height = 0.25 },
						zindex = 200,
					},
				},
				lsp = {
					win = { position = "left" },
					preview = {
						type = "float",
						relative = "editor",
						border = "rounded",
						title = "Preview",
						title_pos = "center",
						position = { 5, -2 },
						size = { width = 0.35, height = 0.25 },
						zindex = 200,
					},
				},

				symbols = {
					win = {
						position = "left",
						wo = {
							foldlevel = 1,
						},
					},
					groups = {},
					format = "{kind_icon} {symbol.name}",
				},
			},
		},
		after = function(_, opts)
			require("trouble").setup(opts)
		end,
		keys = {
			{ "<leader>xx", "<cmd>Trouble my_diag toggle<cr>", desc = "Diagnostics (Trouble)" },
			{ "<leader>xX", "<cmd>Trouble my_diag toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
			{ "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
			{
				"<leader>cS",
				"<cmd>Trouble useful_info toggle win.position=left<cr>",
				desc = "LSP references/definitions/... (Trouble)",
			},
			{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
			{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
			{
				"[q",
				function()
					if require("trouble").is_open() then
						require("trouble").prev({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cprev)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Previous Trouble/Quickfix Item",
			},
			{
				"]q",
				function()
					if require("trouble").is_open() then
						require("trouble").next({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cnext)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Next Trouble/Quickfix Item",
			},
		},
	},
	{
		"which-key.nvim",
		opts = {
			spec = {
				{
					{ "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
				},
			},
		},
	},
	{
		"todo-comments.nvim",
		source = {
			type = "github",
			repo = "todo-comments.nvim",
			owner = "folke",
		},
		build = { useNixpkgs = "todo-comments-nvim" },
		cmd = { "TodoTrouble", "TodoTelescope" },
		event = "User LazyFile",
		after = function()
			local opts = {}
			require("todo-comments").setup(opts)
		end,
		keys = {
			{
				"]t",
				function()
					require("todo-comments").jump_next()
				end,
				desc = "Next Todo Comment",
			},
			{
				"[t",
				function()
					require("todo-comments").jump_prev()
				end,
				desc = "Previous Todo Comment",
			},
			{ "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
			{
				"<leader>xT",
				"<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",
				desc = "Todo/Fix/Fixme (Trouble)",
			},
			{ "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
			{ "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
		}, -- from spec 2,
	},
	-- {
	-- 	"outline.nvim",
	-- 	keys = { { "<leader>cs", "<cmd>Outline<cr>", desc = "Toggle Outline" } },
	-- 	cmd = "Outline",
	-- },
}

return M

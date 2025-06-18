return {
	--TODO: Solve smart-splits issue (annoying)
	--TODO: Debug Adapters (Python)
	--TODO: Look at harpoon
	--TODO: Per-project settings (netcat lsp, for example. See `exrc`)
	{
		"nvim-lspconfig",
		before = function()
			require("lz.n").trigger_load({ "conform.nvim", "blink.cmp", "nvim-navic" })
		end,
		after = function()
			MyVim.intellisense()
		end,
		event = "User LazyFile",
	},
	{
		"conform.nvim",
		event = "User LazyFile",
		lazy = true,
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>cF",
				function()
					require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
				end,
				mode = { "n", "v" },
				desc = "Format Injected Langs",
			},
		},
		beforeAll = function()
			Utils.load_at_startup(function()
				Utils.format.add({
					name = "conform.nvim",
					priority = 100,
					primary = true,
					format = function(buf)
						require("conform").format({ bufnr = buf })
					end,
					sources = function(buf)
						local ret = require("conform").list_formatters(buf)
						return vim.tbl_map(function(v)
							return v.name
						end, ret)
					end,
				})
			end)
		end,
	},
	{
		"trouble.nvim",
		cmd = { "Trouble" },
		after = function()
			local opts = {
				modes = {
					lsp = {
						win = { position = "right" },
					},
				},
			}

			require("trouble").setup(opts)
		end,
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
			{ "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
			{ "<leader>cS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (Trouble)" },
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
	-- {
	-- 	"outline.nvim",
	-- 	keys = { { "<leader>cs", "<cmd>Outline<cr>", desc = "Toggle Outline" } },
	-- 	cmd = "Outline",
	-- },
	{
		"SchemaStore.nvim",
		lazy = true,
	},
	{
		"clangd_extensions.nvim",
		lazy = true,
		cmd = {
			"ClangdSymbolInfo",
			"ClangdTypeHierarchy",
			"ClangdMemoryUsage",
			"ClangdAST",
			"ClangdSwitchSourceHeader",
		},
	},
}

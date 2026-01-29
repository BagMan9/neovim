local M = {}

M.lz_specs = {
	-- 	{
	-- 		"harpoon2",
	-- opts = {
	-- 				menu = {
	-- 					width = vim.api.nvim_win_get_width(0) - 4,
	-- 				},
	-- 				settings = {
	-- 					save_on_toggle = true,
	-- 				},
	-- 			},
	-- 		after = function()
	-- 		end,
	-- 	},
	{
		"inc-rename.nvim",
		source = {
			type = "github",
			repo = "inc-rename.nvim",
			owner = "smjonas",
			branch = "main",
		},
		lazy = false,
		cmd = "IncRename",
		after = function()
			require("inc_rename").setup()
		end,
	},
	{
		"refactoring.nvim",
		source = {
			type = "github",
			repo = "refactoring.nvim",
			owner = "theprimeagen",
			branch = "master",
		},
		build = {
			nixDeps = { "nvim-treesitter", "plenary-nvim" },
		},
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { { "plenary.nvim" }, { "nvim-treesitter" } },
		keys = {
			{ "<leader>r", "", desc = "+refactor", mode = { "n", "v" } },
			{
				"<leader>rs",
				function()
					return require("refactoring").select_refactor()
				end,
				mode = "v",
				expr = true,
				desc = "Refactor",
			},
			{
				"<leader>ri",
				function()
					return require("refactoring").refactor("Inline Variable")
				end,
				expr = true,
				mode = { "n", "v" },
				desc = "Inline Variable",
			},
			{
				"<leader>rb",
				function()
					return require("refactoring").refactor("Extract Block")
				end,
				expr = true,
				desc = "Extract Block",
			},
			{
				"<leader>rf",
				function()
					return require("refactoring").refactor("Extract Block To File")
				end,
				expr = true,
				desc = "Extract Block To File",
			},
			{
				"<leader>rP",
				function()
					return require("refactoring").debug.printf({ below = false })
				end,
				expr = true,
				desc = "Debug Print",
			},
			{
				"<leader>rp",
				function()
					return require("refactoring").debug.print_var({ normal = true })
				end,
				expr = true,
				desc = "Debug Print Variable",
			},
			{
				"<leader>rc",
				function()
					return require("refactoring").debug.cleanup({})
				end,
				expr = true,
				desc = "Debug Cleanup",
			},
			{
				"<leader>rf",
				function()
					return require("refactoring").refactor("Extract Function")
				end,
				expr = true,
				mode = "v",
				desc = "Extract Function",
			},
			{
				"<leader>rF",
				function()
					return require("refactoring").refactor("Extract Function To File")
				end,
				expr = true,
				mode = "v",
				desc = "Extract Function To File",
			},
			{
				"<leader>rx",
				function()
					return require("refactoring").refactor("Extract Variable")
				end,
				expr = true,
				mode = "v",
				desc = "Extract Variable",
			},
			{
				"<leader>rr",
				function()
					require("refactoring").select_refactor()
				end,
				mode = { "n", "v" },
			},
		},
		after = function()
			local opts = {
				prompt_func_return_type = {
					go = false,
					java = false,
					cpp = true,
					c = true,
					h = true,
					hpp = true,
					cxx = true,
				},
				prompt_func_param_type = {
					go = false,
					java = false,
					cpp = true,
					c = true,
					h = true,
					hpp = true,
					cxx = true,
				},
				printf_statements = {},
				print_var_statements = {},
				show_success_message = true,
			}

			require("refactoring").setup(opts)
		end,
		lazy = false,
	},
	{
		"neogen",
		cmd = "Neogen",
		source = {
			type = "github",
			repo = "neogen",
			owner = "danymat",
		},
		keys = {
			{
				"<leader>cn",
				function()
					require("neogen").generate()
				end,
				desc = "Generate Annotations (Neogen)",
			},
		},
		after = function()
			local opts = {
				snippet_engine = "luasnip",
			}
			require("neogen").setup(opts)
		end,
	},
	{
		"neo-tree.nvim",
		cmd = "Neotree",
		source = {
			type = "github",
			repo = "neo-tree.nvim",
			owner = "nvim-neo-tree",
		},
		build = {
			nixDeps = {
				"plenary-nvim",
				"nui-nvim",
			},
			useNixpkgs = "neo-tree-nvim",
			skipModules = { "neo-tree.types.fixes.compat-0.10" },
		},
		keys = {
			{ "<leader>e", "<cmd>Neotree filesystem toggle right<CR>", desc = "File Explorer" },
		},
		opts = {
			window = {
				position = "left",
				width = 30,
			},
			event_handlers = {
				{
					event = "neo_tree_buffer_enter",
					handler = function()
						vim.cmd("highlight! Cursor blend=100")
					end,
				},
				{
					event = "neo_tree_buffer_leave",
					handler = function()
						-- Make this whatever your current Cursor highlight group is.
						vim.cmd("highlight! Cursor blend=0")
					end,
				},
			},
		},
		after = function(_, opts)
			require("neo-tree").setup(opts)
		end,
	},
	{
		"mini.pairs",
		source = {
			type = "github",
			repo = "mini.pairs",
			owner = "nvim-mini",
		},
		event = "VeryLazy",
		opts = {
			modes = { insert = true, command = true, terminal = false },
			-- skip autopair when next character is one of these
			skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
			-- skip autopair when the cursor is inside these treesitter nodes
			skip_ts = { "string" },
			-- skip autopair when next character is closing pair
			-- and there are more closing pairs than opening pairs
			skip_unbalanced = true,
			-- better deal with markdown code blocks
			markdown = true,
		},
		after = function(_, opts)
			Utils.pairs(opts)
		end,
	},
}

return M

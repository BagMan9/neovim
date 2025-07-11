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
		lazy = false,
		cmd = "IncRename",
		after = function()
			require("inc_rename").setup()
		end,
	},
	{
		"refactoring.nvim",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = { { "plenary.nvim" } },
		keys = {
			{ "<leader>r", "", desc = "+refactor", mode = { "n", "v" } },
			{
				"<leader>rs",
				function()
					require("refactoring").select_refactor()
				end,
				mode = "v",
				desc = "Refactor",
			},
			{
				"<leader>ri",
				function()
					require("refactoring").refactor("Inline Variable")
				end,
				mode = { "n", "v" },
				desc = "Inline Variable",
			},
			{
				"<leader>rb",
				function()
					require("refactoring").refactor("Extract Block")
				end,
				desc = "Extract Block",
			},
			{
				"<leader>rf",
				function()
					require("refactoring").refactor("Extract Block To File")
				end,
				desc = "Extract Block To File",
			},
			{
				"<leader>rP",
				function()
					require("refactoring").debug.printf({ below = false })
				end,
				desc = "Debug Print",
			},
			{
				"<leader>rp",
				function()
					require("refactoring").debug.print_var({ normal = true })
				end,
				desc = "Debug Print Variable",
			},
			{
				"<leader>rc",
				function()
					require("refactoring").debug.cleanup({})
				end,
				desc = "Debug Cleanup",
			},
			{
				"<leader>rf",
				function()
					require("refactoring").refactor("Extract Function")
				end,
				mode = "v",
				desc = "Extract Function",
			},
			{
				"<leader>rF",
				function()
					require("refactoring").refactor("Extract Function To File")
				end,
				mode = "v",
				desc = "Extract Function To File",
			},
			{
				"<leader>rx",
				function()
					require("refactoring").refactor("Extract Variable")
				end,
				mode = "v",
				desc = "Extract Variable",
			},
			{
				"<leader>rp",
				function()
					require("refactoring").debug.print_var()
				end,
				mode = "v",
				desc = "Debug Print Variable",
			},
		},
		after = function()
			local opts = {
				prompt_func_return_type = {
					go = false,
					java = false,
					cpp = false,
					c = false,
					h = false,
					hpp = false,
					cxx = false,
				},
				prompt_func_param_type = {
					go = false,
					java = false,
					cpp = false,
					c = false,
					h = false,
					hpp = false,
					cxx = false,
				},
				printf_statements = {},
				print_var_statements = {},
				show_success_message = true,
			}

			require("refactoring").setup(opts)
		end,
	},
	{
		"neogen",
		cmd = "Neogen",
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
		keys = {
			{ "<leader>e", "<cmd>Neotree filesystem toggle left<CR>", desc = "File Explorer" },
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

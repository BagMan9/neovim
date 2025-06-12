return {
{
		"harpoon2",
		after = function()
			local opts = {
				menu = {
					width = vim.api.nvim_win_get_width(0) - 4,
				},
				settings = {
					save_on_toggle = true,
				},
			}
		end,
	},
{
		"grug-far.nvim",
		after = function()
			local opts = { headerMaxWidth = 80 }
		end,
		cmd = "GrugFar",
		keys = {
			{
				"<leader>sr",
				function()
					local grug = require("grug-far")
					local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
					grug.open({
						transient = true,
					prefills = {
							filesFilter = ext and ext ~= "" and "*." .. ext or nil,
						},
					})
				end,
				mode = { "n", "v" },
				desc = "Search and Replace",
			},
		},
	},
{
		"inc-rename.nvim",
		cmd = "IncRename",
    keys = {
      {
				"<leader>cr",
			},
    },
	},
	{
		"todo-comments.nvim",
		cmd = { "TodoTrouble", "TodoTelescope" },
		-- event = "LazyFile",
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
{
		"lazydev.nvim",
		ft = "lua",
		cmd = "LazyDev",
	},
}

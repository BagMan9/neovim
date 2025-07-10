local M = {}

M.lz_specs = {
	{
		"flash.nvim",
		dependencies = {
			{ "vim-repeat" },
		},
		event = "User LazyFile",
		opts = { modes = { char = { jump_labels = true } } },
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"S",
				mode = { "n", "o", "x" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
			{
				"R",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Treesitter Search",
			},
			{
				"<c-s>",
				mode = { "c" },
				function()
					require("flash").toggle()
				end,
				desc = "Toggle Flash Search",
			},
		},
		after = function(_, opts)
			require("flash").setup(opts)
		end,
	},
	{
		"mini.ai",
		event = "VeryLazy",
		opts = {
			n_lines = 500,
			custom_textobjects = {
				o = require("mini.ai").gen_spec.treesitter({ -- code block
					a = { "@block.outer", "@conditional.outer", "@loop.outer" },
					i = { "@block.inner", "@conditional.inner", "@loop.inner" },
				}),
				f = require("mini.ai").gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
				c = require("mini.ai").gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
				t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
				d = { "%f[%d]%d+" }, -- digits
				e = { -- Word with case
					{
						"%u[%l%d]+%f[^%l%d]",
						"%f[%S][%l%d]+%f[^%l%d]",
						"%f[%P][%l%d]+%f[^%l%d]",
						"^[%l%d]+%f[^%l%d]",
					},
					"^().*()$",
				},
				g = Utils.ai_buffer, -- buffer
				u = require("mini.ai").gen_spec.function_call(), -- u for "Usage"
				U = require("mini.ai").gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
			},
		},
		after = function(_, opts)
			require("mini.ai").setup(opts)
		end,
	},
	{
		--NOTE: Not setting keys because I don't need it probably, do not forget
		"comment.nvim",
		event = "User LazyFile",
		dependencies = {
			{ "nvim-ts-context-commentstring" },
		},
		after = function(_, opts)
			require("Comment").setup(opts)
		end,
	},
	{
		"nvim-surround",
		event = "User LazyFile",
		opts = {
			keymaps = {
				normal = "yz",
				normal_cur = "yzz",
				normal_line = "yZ",
				normal_cur_line = "yZZ",
				visual = "Z",
				visual_line = "gZ",
				delete = "dz",
				change = "cz",
				change_line = "cZ",
			},
		},
		after = function(_, opts)
			require("nvim-surround").setup(opts)
		end,
	},
	{
		"yanky.nvim",
		event = "User LazyFile",
		opts = {
			highlight = { timer = 150 },
		},
		after = function(_, opts)
			require("yanky").setup(opts)
		end,
		keys = {
			{
				"<leader>p",
				function()
					vim.cmd([[YankyRingHistory]])
				end,
				mode = { "n", "x" },
				desc = "Open Yank History",
			},
			{ "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank Text" },
			{ "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put Text After Cursor" },
			{ "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Cursor" },
			{ "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put Text After Selection" },
			{ "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Selection" },
			{ "[y", "<Plug>(YankyCycleForward)", desc = "Cycle Forward Through Yank History" },
			{ "]y", "<Plug>(YankyCycleBackward)", desc = "Cycle Backward Through Yank History" },
			{ "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put Indented After Cursor (Linewise)" },
			{ "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put Indented Before Cursor (Linewise)" },
			{ "]P", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put Indented After Cursor (Linewise)" },
			{ "[P", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put Indented Before Cursor (Linewise)" },
			{ ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and Indent Right" },
			{ "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and Indent Left" },
			{ ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put Before and Indent Right" },
			{ "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put Before and Indent Left" },
			{ "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put After Applying a Filter" },
			{ "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put Before Applying a Filter" },
		},
	},
}

return M

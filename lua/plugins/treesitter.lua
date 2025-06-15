return {
	{
		"nvim-treesitter-context",
		-- event = "LazyFile",
	},
	{
		"nvim-treesitter",
		after = function()
			local opts = {
				highlight = { enable = false },
				indent = { enable = true },
				enable = true,
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = false,
						node_decremental = "<bs>",
					},
				},
				textobjects = {
					move = {
						enable = true,
						goto_next_start = {
							["]f"] = "@function.outer",
							["]c"] = "@class.outer",
							["]a"] = "@parameter.inner",
						},
						goto_next_end = {
							["]F"] = "@function.outer",
							["]C"] = "@class.outer",
							["]A"] = "@parameter.inner",
						},
						goto_previous_start = {
							["[f"] = "@function.outer",
							["[c"] = "@class.outer",
							["[a"] = "@parameter.inner",
						},
						goto_previous_end = {
							["[F"] = "@function.outer",
							["[C"] = "@class.outer",
							["[A"] = "@parameter.inner",
						},
					},
				},
			}
			require("nvim-treesitter").setup()
			require("nvim-treesitter.configs").setup(opts)
		end,
		extension = { rasi = "rasi", rofi = "rasi", wofi = "rasi" },
		filename = {
			["vifmrc"] = "vim",
		},
		pattern = {
			[".*/waybar/config"] = "jsonc",
			[".*/mako/config"] = "dosini",
			[".*/kitty/.+%.conf"] = "kitty",
			[".*/hypr/.+%.conf"] = "hyprlang",
			["%.env%.[%w_.-]+"] = "sh",
		},
		-- "LazyFile" removed from here
		event = { "DeferredUIEnter" },
		lazy = vim.fn.argc(-1) == 0,
	},
	{
		"nvim-treesitter-textobjects",
		event = "DeferredUIEnter",
		enabled = true,
	},
	{
		"nvim-ts-autotag",
		event = "User LazyFile",
	},
	{
		"nvim-ts-context-commentstring",
		lazy = true,
	},
	{
		"ts-comments.nvim",
		event = "DeferredUIEnter",
	},
}

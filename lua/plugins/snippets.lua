local M = {}

M.lz_specs = {
	{
		"luasnip",
		build = { useNixpkgs = "luasnip" },
		dependencies = { "friendly-snippets" },
		lazy = true,
		after = function()
			require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.env.HOME .. "/.config/nvim/snippets" } })
			require("luasnip.loaders.from_vscode").lazy_load()
		end,
	},
	{
		"friendly-snippets",
		build = { useNixpkgs = "friendly-snippets" },
	},
	{
		"nvim-scissors",
		source = {
			type = "github",
			repo = "nvim-scissors",
			owner = "chrisgrieser",
			branch = "main",
		},
		build = {
			useNixpkgs = "nvim-scissors",
		},
		keys = {
			{
				"<leader>sA",
				mode = { "n", "x" },
				function()
					require("scissors").addNewSnippet()
				end,
				desc = "Add Snippet",
			},
			{
				"<leader>se",
				mode = { "n" },
				function()
					require("scissors").editSnippet()
				end,
				desc = "Edit Snippet",
			},
		},
		after = function()
			require("scissors").setup({
				snippetDir = vim.env.HOME .. "/.config/nvim/snippets",
			})
		end,
	},
	{
		"blink.cmp",
		opts = {
			snippets = {
				preset = "luasnip",
			},
		},
	},
}

return M

return {
	{
		"nvim-lspconfig",
		extraPackages = { "lua-language-server" },
		opts = {
			servers = {
				lua_ls = {
					settings = {
						Lua = {
							workspace = {
								checkThirdParty = false,
								library = {
									vim.env.VIMRUNTIME,
								},
							},
							codeLens = {
								enable = false,
							},
							completion = {
								callSnippet = "Replace",
							},
							doc = {
								privateName = { "^_" },
							},
							hint = {
								enable = false,
								setType = false,
								paramType = true,
								paramName = "Disable",
								semicolon = "Disable",
								arrayIndex = "Disable",
							},
						},
					},
				},
			},
		},
	},
	{
		"conform.nvim",
		source = {
			type = "github",
			repo = "conform.nvim",
			owner = "stevearc",
		},
		extraPackages = { "stylua" },
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
			},
		},
	},
	{
		"lazydev.nvim",
		source = {
			type = "github",
			repo = "lazydev.nvim",
			owner = "folke",
		},
		ft = "lua",
		cmd = "LazyDev",
		after = function()
			require("lazydev").setup()
		end,
	},
}

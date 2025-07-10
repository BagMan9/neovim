return {
	{
		"nvim-lspconfig",
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
								enable = true,
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
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
			},
		},
	},
	{
		"lazydev.nvim",
		ft = "lua",
		cmd = "LazyDev",
		after = function()
			require("lazydev").setup()
		end,
	},
}

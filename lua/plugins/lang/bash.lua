return {
	{
		"nvim-lspconfig",
		extraPackages = {
			"bash-language-server",
		},
		opts = {
			servers = {
				bashls = {
					enabled = true,
				},
			},
		},
	},
	{
		"conform.nvim",
		extraPackages = {
			"shfmt",
		},
		opts = {
			formatters_by_ft = {
				sh = { "shfmt" },
			},
		},
	},
}

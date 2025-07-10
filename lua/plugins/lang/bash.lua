return {
	{
		"nvim-lspconfig",
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
		opts = {
			formatters_by_ft = {
				sh = { "shfmt" },
			},
		},
	},
}

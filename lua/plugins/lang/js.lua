return {
	{
		"nvim-lspconfig",
		extraPackages = {
			"svelte-language-server",
			"typescript-language-server",
		},
		opts = {
			servers = {
				ts_ls = {
					enabled = true,
				},
				svelte = {
					enabled = true,
				},
			},
		},
	},
}

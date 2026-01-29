return {
	{
		"nvim-lspconfig",
		extraPackages = {
			"vscode-json-languageserver",
		},
		opts = {
			servers = {
				jsonls = {
					-- lazy-load schemastore when needed
					on_new_config = function(new_config)
						if require("lz.n").lookup("SchemaStore.nvim") then
							require("lz.n").trigger_load("SchemaStore.nvim")
						end
						new_config.settings.json.schemas = new_config.settings.json.schemas or {}
						vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
					end,
					settings = {
						json = {
							format = {
								enable = true,
							},
							validate = { enable = true },
						},
					},
				},
			},
		},
	},
}

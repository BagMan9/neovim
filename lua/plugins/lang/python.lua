return {
	{
		"nvim-lspconfig",
		opts = {
			servers = {
				ruff = {
					enabled = true,
					cmd_env = { RUFF_TRACE = "messages" },
					init_options = {
						settings = {
							-- This makes ruff prefer settings defined in pyproject.toml
							configurationPreference = "filesystemFirst",
							logLevel = "error",

							configuration = {
								-- lint = {
								-- 	["extend-select"] = {},
								-- },
								format = {
									["docstring-code-format"] = true,
									["quote-style"] = "double",
								},
							},
						},
					},
					-- FIXME: Port LazyVim lsp.action or replace
					-- keys = {
					--   {
					--     "<leader>co",
					--     LazyVim.lsp.action["source.organizeImports"],
					--     desc = "Organize Imports",
					--   },
					-- },
				},
				basedpyright = {
					enabled = true,
					settings = {
						basedpyright = {
							disableOrganizeImports = true,
							analysis = {
								diagnosticMode = "workspace",
								inlay_hints = {
									variableTypes = true,
									callArgumentNames = true,
									functionReturnTypes = true,
								},
							},
						},
					},
				},
			},
			setup = {
				ruff = function()
					Utils.lsp.on_attach(function(client, _)
						client.server_capabilities.hoverProvider = false
					end, "ruff")
				end,
			},
		},
	},
	{
		"conform.nvim",
		opts = {
			formatters_by_ft = {
				python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
			},
		},
	},
	{
		lazy = false,
		"nvim-dap-python",
		after = function()
			require("dap-python").setup("debugpy-adapter")
		end,
	},
}

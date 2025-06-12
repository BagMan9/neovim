---@class MyVim.intellisense
local M = {}

setmetatable(M, {
	__call = function(m, ...)
		return m.setup(...)
	end,
})

M.config = {
	lsp = {
		---@type vim.diagnostic.Opts
		diagnostics = {
			underline = true,
			update_in_insert = false,
			virtual_text = false,
			virtual_lines = true,
			severity_sort = true,
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = Utils.lazy_defaults.icons.diagnostics.Error,
					[vim.diagnostic.severity.WARN] = Utils.lazy_defaults.icons.diagnostics.Warn,
					[vim.diagnostic.severity.HINT] = Utils.lazy_defaults.icons.diagnostics.Hint,
					[vim.diagnostic.severity.INFO] = Utils.lazy_defaults.icons.diagnostics.Info,
				},
			},
		},
		-- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
		inlay_hints = {
			enabled = true,
			exclude = {},
		},
		-- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
		codelens = {
			enabled = false,
		},
		-- Force on capabilities
		capabilities = {
			workspace = {
				fileOperations = {
					didRename = true,
					willRename = true,
				},
			},
		},
		---@type vim.lsp.buf.format.Opts
		format = {
			formatting_options = nil,
			timeout_ms = nil,
		},
		---@type vim.lsp.ClientConfig[]
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
							enable = true,
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
			jsonls = {
				-- lazy-load schemastore when needed
				on_new_config = function(new_config)
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
			clangd = {
				keys = {
					{
						"<leader>ch",
						"<cmd>ClangdSwitchSourceHeader<cr>",
						desc = "Switch Source/Header (C/C++)",
					},
				},
				root_dir = function(fname)
					--TODO: This will need fixing!
					return require("lspconfig.util").root_pattern(
						"Makefile",
						"configure.ac",
						"configure.in",
						"config.h.in",
						"meson.build",
						"meson_options.txt",
						"build.ninja"
					)(fname) or require("lspconfig.util").root_pattern(
						"compile_commands.json",
						"compile_flags.txt"
					)(fname) or require("lspconfig.util").find_git_ancestor(fname)
				end,
				capabilities = {
					offsetEncoding = { "utf-16" },
				},
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
					"--function-arg-placeholders",
					"--fallback-style=llvm",
				},
				init_options = {
					usePlaceholders = true,
					completeUnimported = true,
					clangdFileStatus = true,
				},
			},
			ruff = {
				cmd_env = { RUFF_TRACE = "messages" },
				init_options = {
					settings = {
						logLevel = "error",
					},
				},
				-- keys = {
				--   {
				--     "<leader>co",
				--     LazyVim.lsp.action["source.organizeImports"],
				--     desc = "Organize Imports",
				--   },
				-- },
			},
			pyright = {
				enabled = true,
			},
			ruff_lsp = {
				-- keys = {
				--   {
				--     "<leader>co",
				--     LazyVim.lsp.action["source.organizeImports"],
				--     desc = "Organize Imports",
				--   },
				-- },
			},

			bashls = {},
		},
		-- setup = {
		-- 	[ruff] = function()
		-- 		LazyVim.lsp.on_attach(function(client, _)
		-- 			-- Disable hover in favor of Pyright
		-- 			client.server_capabilities.hoverProvider = false
		-- 		end, ruff)
		-- 	end,
		-- },
	},

	conform = {
		formatters_by_ft = {
			nix = { "nixfmt" },
			lua = { "stylua" },
			fish = { "fish_indent" },
			sh = { "shfmt" },
		},
		default_format_opts = {
			timeout_ms = 3000,
			async = false, -- not recommended to change
			quiet = false, -- not recommended to change
			lsp_format = "fallback", -- not recommended to change
		},
		formatters = {
			injected = { options = { ignore_errors = true } },
		},
	},
}

M._dynamic_keys = {}

function M.setup()
	-- Conform is not super important on first enter, can be set for later
	Utils.defer(M.format_setup)

	Utils.format.add(Utils.lsp.formatter())

	Utils.lsp.setup()
	M.init_keys()

	if M.config.lsp.inlay_hints.enabled then
		Utils.lsp.on_supports_method("textDocument/inlayHint", function(client, buffer)
			if
				vim.api.nvim_buf_is_valid(buffer)
				and vim.bo[buffer].buftype == ""
				and not vim.tbl_contains(M.config.lsp.inlay_hints.exclude, vim.bo[buffer].filetype)
			then
				vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
			end
		end)
	end
	if M.config.lsp.codelens.enabled and vim.lsp.codelens then
		Utils.lsp.on_supports_method("textDocument/codeLens", function(client, buffer)
			vim.lsp.codelens.refresh()
			vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
				buffer = buffer,
				callback = vim.lsp.codelens.refresh,
			})
		end)
	end

	-- Put virtual text / diag config here

	vim.diagnostic.config(vim.deepcopy(M.config.lsp.diagnostics))

	-- Clean this up
	local servers = M.config.lsp.servers
	local capabilities = vim.tbl_deep_extend(
		"force",
		{},
		vim.lsp.protocol.make_client_capabilities(),
		require("blink.cmp").get_lsp_capabilities() or {},
		M.config.lsp.capabilities or {}
	)

	local function setup(server)
		local server_opts = vim.tbl_deep_extend("force", {
			capabilities = vim.deepcopy(capabilities),
		}, servers[server] or {})
		-- Move codelens / capabilities / inlay_hints check into here

		if server_opts.enabled == false then
			return
		end
		vim.lsp.enable(server)
		vim.lsp.config(server, server_opts)
	end

	for server, server_opts in pairs(servers) do
		setup(server)
	end
end

function M.format_setup(opts)
	require("conform").setup(M.config.conform)

	vim.api.nvim_create_autocmd("BufWritePre", {
		group = vim.api.nvim_create_augroup("Format", {}),
		callback = function(event)
			Utils.format({ buf = event.buf })
		end,
	})

	vim.api.nvim_create_user_command("Format", function()
		Utils.format({ force = true })
	end, { desc = "Format selection or buffer" })
end

function M.init_keys()
	Utils.lsp.on_attach(function(client, buffer)
		Utils.lsp.keys.on_attach(client, buffer)
	end)

	Utils.lsp.on_dynamic_capability(Utils.lsp.keys.on_attach)
end

return M

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
		inlay_hints = {
			enabled = true,
			exclude = {},
		},
		codelens = {
			enabled = true,
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
			nixd = {
				enabled = true,
				cmd = { "nixd", "--semantic-tokens=true" },
				settings = {
					nixd = {
						nixpkgs = {
							expr = "import <nixpkgs> { }",
						},
						formatting = {
							command = { "nixfmt" },
						},
						options = {
							["nix-darwin"] = {
								expr = [[(builtins.getFlake  ("git+file://" + toString ./.)).darwinConfigurations.Isaacs-MacBook-Pro.options]],
							},
							nixos = {
								expr = [[(builtins.getFlake  ("git+file://" + toString ./.)).nixosConfigurations.Isaac-NixOS.options]],
							},
							["home-manager"] = {
								expr = '(builtins.getFlake  ("git+file://" + toString ./.)).darwinConfigurations.Isaacs-MacBook-Pro.options.home-manager.users.type.getSubOptions []',
							},
						},
					},
				},
			},
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
			yamlls = {
				capabilities = {
					textDocument = {
						foldingRange = {
							dynamicRegistration = false,
							lineFoldingOnly = true,
						},
					},
				},
				on_new_config = function(new_config)
					new_config.settings.yaml.schemas = vim.tbl_deep_extend(
						"force",
						new_config.settings.yaml.schemas or {},
						require("schemastore").yaml.schemas()
					)
				end,
				settings = {
					redhat = { telemetry = { enabled = false } },
					yaml = {
						keyOrdering = false,
						format = {
							enable = true,
						},
						validate = true,
						schemaStore = {
							-- Must disable built-in schemaStore support to use
							-- schemas from SchemaStore.nvim plugin
							enable = false,
							-- Avoid TypeError: Cannot read properties of undefined (reading 'length')
							url = "",
						},
					},
				},
			},
			clangd = {
				keys = {
					-- MAYBE: Setup more clangd-extensions stuff
					{
						"<leader>ch",
						function()
							return "<cmd>ClangdSwitchSourceHeader<cr>"
						end,
						desc = "Switch Source/Header (C/C++)",
					},
				},
				root_dir = function(fname)
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

			bashls = {
				enabled = true,
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

	conform = {
		formatters_by_ft = {
			python = { "ruff_fix", "ruff_format", "ruff_organize_imports" },
			nix = { "nixfmt" },
			lua = { "stylua" },
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

M._dynamic_keys = nil

function M.get()
	if M._dynamic_keys then
		return M._dynamic_keys
	end

	M._dynamic_keys = {
		{
			"<leader>cl",
			function()
				require("snacks").picker.lsp_config()
			end,
			desc = "Lsp Info",
		},
		{
			"gd",
			function()
				require("snacks").picker.lsp_definitions()
			end,
			desc = "Goto Definition",
			has = "definition",
		},
		{
			"gr",
			function()
				require("snacks").picker.lsp_references()
			end,
			desc = "References",
			nowait = true,
		},
		{
			"gI",
			function()
				require("snacks").picker.lsp_implementations()
			end,
			desc = "Goto Implementation",
		},
		{
			"gy",
			function()
				require("snacks").picker.lsp_type_definitions()
			end,
			desc = "Goto T[y]pe Definition",
		},
		{
			"<leader>cr",
			function()
				return ":IncRename" .. " " .. vim.fn.expand("<cword>")
			end,
			expr = true,
			desc = "Rename (inc-rename.nvim)",
			has = "rename",
			-- needs = "inc-rename.nvim",
		},
		{ "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
		{
			"<leader>ss",
			function()
				require("snacks").picker.lsp_symbols({ filter = Utils.lazy_defaults.kind_filter })
			end,
			desc = "LSP Symbols",
			has = "documentSymbol",
		},
		{
			"<leader>sS",
			function()
				require("snacks").picker.lsp_workspace_symbols({
					filter = Utils.lazy_defaults.kind_filter,
				})
			end,
			desc = "LSP Workspace Symbols",
			has = "workspace/symbols",
		},
		{
			"K",
			function()
				return vim.lsp.buf.hover()
			end,
			desc = "Hover",
		},
		{
			"gK",
			function()
				return vim.lsp.buf.signature_help()
			end,
			desc = "Signature Help",
			has = "signatureHelp",
		},
		{
			"<c-k>",
			function()
				return vim.lsp.buf.signature_help()
			end,
			mode = "i",
			desc = "Signature Help",
			has = "signatureHelp",
		},
		{ "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" },
		{ "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" }, has = "codeLens" },
		{
			"<leader>cC",
			vim.lsp.codelens.refresh,
			desc = "Refresh & Display Codelens",
			mode = { "n" },
			has = "codeLens",
		},
		{
			"<leader>cR",
			function()
				require("snacks").rename.rename_file()
			end,
			desc = "Rename File",
			mode = { "n" },
			has = { "workspace/didRenameFiles", "workspace/willRenameFiles" },
		},
		-- { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
		-- { "<leader>cA", LazyVim.lsp.action.source, desc = "Source Action", has = "codeAction" },
		{
			"]]",
			function()
				require("snacks").words.jump(vim.v.count1)
			end,
			has = "documentHighlight",
			desc = "Next Reference",
			cond = function()
				return require("snacks").words.is_enabled()
			end,
		},
		{
			"[[",
			function()
				require("snacks").words.jump(-vim.v.count1)
			end,
			has = "documentHighlight",
			desc = "Prev Reference",
			cond = function()
				return require("snacks").words.is_enabled()
			end,
		},
		{
			"<a-n>",
			function()
				require("snacks").words.jump(vim.v.count1, true)
			end,
			has = "documentHighlight",
			desc = "Next Reference",
			cond = function()
				return require("snacks").words.is_enabled()
			end,
		},
		{
			"<a-p>",
			function()
				require("snacks").words.jump(-vim.v.count1, true)
			end,
			has = "documentHighlight",
			desc = "Prev Reference",
			cond = function()
				return require("snacks").words.is_enabled()
			end,
		},
	}
	return M._dynamic_keys
end

function M.setup()
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

		if M.config.lsp.setup[server] then
			if M.config.lsp.setup[server](server, server_opts) then
				return
			end
		end
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

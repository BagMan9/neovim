return {
	--TODO:
	-- Get all keybinds good
	-- Todo highlights off + other general coloring
	-- Finish all plugins in toprocess
	-- ONCE ALL "DONE":
	-- Solve smart-splits issue (annoying)
	-- Make smart-splits switch wm commands
	-- Clean up whichkey
	-- Consalidate configs / fully organize / refactor
	-- Go through lazyvim website one last time
	-- Figure out if things can go faster
	--
	{
		"nvim-lspconfig",
		-- TODO: Refactor once working
		before = function()
			require("lz.n").trigger_load({ "conform.nvim", "blink.cmp" })
		end,
		after = function()
			local opts = {
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
				-- Be aware that you also will need to properly configure your LSP server to
				-- provide the inlay hints.
				inlay_hints = {
					enabled = true,
					exclude = { "vue" }, -- filetypes for which you don't want to enable inlay hints
				},
				-- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
				-- Be aware that you also will need to properly configure your LSP server to
				-- provide the code lenses.
				codelens = {
					enabled = false,
				},
				-- add any global capabilities here
				capabilities = {
					workspace = {
						fileOperations = {
							didRename = true,
							willRename = true,
						},
					},
				},
				-- options for vim.lsp.buf.format
				-- `bufnr` and `filter` is handled by the LazyVim formatter,
				-- but can be also overridden when specified
				format = {
					formatting_options = nil,
					timeout_ms = nil,
				},
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
			}
			-- setup autoformat
			-- TODO: Setup LSP + Non-lsp formatters
			Utils.format.add(Utils.lsp.formatter())

			-- setup keymaps
			Utils.lsp.on_attach(function(client, buffer)
				Utils.lsp.keys.on_attach(client, buffer)
			end)

			Utils.lsp.setup()
			Utils.lsp.on_dynamic_capability(Utils.lsp.keys.on_attach)

			-- diagnostics signs
			-- TODO: Probably remove
			-- if vim.fn.has("nvim-0.10.0") == 0 then
			-- 	if type(opts.diagnostics.signs) ~= "boolean" then
			-- 		for severity, icon in pairs(opts.diagnostics.signs.text) do
			-- 			local name = vim.diagnostic.severity[severity]:lower():gsub("^%l", string.upper)
			-- 			name = "DiagnosticSign" .. name
			-- 			vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
			-- 		end
			-- 	end
			-- end
			--
			--   inlay hints
			if opts.inlay_hints.enabled then
				Utils.lsp.on_supports_method("textDocument/inlayHint", function(client, buffer)
					if
						vim.api.nvim_buf_is_valid(buffer)
						and vim.bo[buffer].buftype == ""
						and not vim.tbl_contains(opts.inlay_hints.exclude, vim.bo[buffer].filetype)
					then
						vim.lsp.inlay_hint.enable(true, { bufnr = buffer })
					end
				end)
			end

			-- code lens
			if opts.codelens.enabled and vim.lsp.codelens then
				Utils.lsp.on_supports_method("textDocument/codeLens", function(client, buffer)
					vim.lsp.codelens.refresh()
					vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
						buffer = buffer,
						callback = vim.lsp.codelens.refresh,
					})
				end)
			end

			if type(opts.diagnostics.virtual_text) == "table" and opts.diagnostics.virtual_text.prefix == "icons" then
				opts.diagnostics.virtual_text.prefix = vim.fn.has("nvim-0.10.0") == 0 and "●"
					or function(diagnostic)
						local icons = Utils.lazy_defaults.icons.diagnostics
						for d, icon in pairs(icons) do
							if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
								return icon
							end
						end
					end
			end

			vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

			local servers = opts.servers
			local capabilities = vim.tbl_deep_extend(
				"force",
				{},
				vim.lsp.protocol.make_client_capabilities(),
				require("blink.cmp").get_lsp_capabilities() or {},
				opts.capabilities or {}
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
		end,
		event = "User LazyFile",
	},
	{
		"conform.nvim",
		after = function()
			---@type conform.setupOpts
			local opts = {
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
				--MERGE POINT
			}
			Utils.format.setup(opts)
		end,
		event = "User LazyFile",
		lazy = true,
		cmd = "ConformInfo",
		keys = {
			{
				"<leader>cF",
				function()
					require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
				end,
				mode = { "n", "v" },
				desc = "Format Injected Langs",
			},
		},
		beforeAll = function()
			Utils.load_at_startup(function()
				Utils.format.add({
					name = "conform.nvim",
					priority = 100,
					primary = true,
					format = function(buf)
						require("conform").format({ bufnr = buf })
					end,
					sources = function(buf)
						local ret = require("conform").list_formatters(buf)
						return vim.tbl_map(function(v)
							return v.name
						end, ret)
					end,
				})
			end)
		end,
	},
	{
		"trouble.nvim",
		cmd = { "Trouble" },
		after = function()
			local opts = {
				modes = {
					lsp = {
						win = { position = "right" },
					},
				},
			}

			require("trouble").setup(opts)
		end,
		keys = {
			{ "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
			{ "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
			{ "<leader>cs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
			{ "<leader>cS", "<cmd>Trouble lsp toggle<cr>", desc = "LSP references/definitions/... (Trouble)" },
			{ "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
			{ "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
			{
				"[q",
				function()
					if require("trouble").is_open() then
						require("trouble").prev({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cprev)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Previous Trouble/Quickfix Item",
			},
			{
				"]q",
				function()
					if require("trouble").is_open() then
						require("trouble").next({ skip_groups = true, jump = true })
					else
						local ok, err = pcall(vim.cmd.cnext)
						if not ok then
							vim.notify(err, vim.log.levels.ERROR)
						end
					end
				end,
				desc = "Next Trouble/Quickfix Item",
			},
		}, -- from spec 2,
	},
	{
		"outline.nvim",
		keys = { { "<leader>cs", "<cmd>Outline<cr>", desc = "Toggle Outline" } },
		cmd = "Outline",
	},
}

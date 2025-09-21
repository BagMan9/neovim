return {
	{
		"nvim-lspconfig",
		dependencies = {
			{ "conform.nvim" },
			{ "blink.cmp" },
			{ "SchemaStore.nvim" },
		},
		opts = {

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
				exclude = { "swift" },
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
		},
		after = function(_, opts)
			Utils.format.add(Utils.lsp.formatter())

			Utils.lsp.setup()

			MyVim.intellisense.init_keys()

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
			if opts.codelens.enabled and vim.lsp.codelens then
				Utils.lsp.on_supports_method("textDocument/codeLens", function(client, buffer)
					vim.lsp.codelens.refresh()
					vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "InsertLeave" }, {
						buffer = buffer,
						callback = vim.lsp.codelens.refresh,
					})
				end)
			end

			-- Put virtual text / diag config here

			vim.diagnostic.config(vim.deepcopy(opts.diagnostics))

			-- Clean this up
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

				if opts.setup[server] then
					if opts.setup[server](server, server_opts) then
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
		end,
		event = "User LazyFile",
	},
	{
		"conform.nvim",
		event = "User LazyFile",
		lazy = true,
		cmd = "ConformInfo",
		opts = {
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
		after = function(_, opts)
			require("conform").setup(opts)

			vim.api.nvim_create_autocmd("BufWritePre", {
				group = vim.api.nvim_create_augroup("Format", {}),
				callback = function(event)
					Utils.format({ buf = event.buf })
				end,
			})

			vim.api.nvim_create_user_command("Format", function()
				Utils.format({ force = true })
			end, { desc = "Format selection or buffer" })
		end,
		init = function()
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
		"nvim-lint",
		enabled = true,
		event = "User LazyFile",
		opts = {
			-- Event to trigger linters
			events = { "BufWritePost", "BufReadPost", "InsertLeave" },
			-- LazyVim extension to easily override linter options
			-- or add custom linters.
			---@type table<string,table>
			linters = {},
		},
		after = function(_, opts)
			local L = {}

			local lint = require("lint")
			for name, linter in pairs(opts.linters) do
				if type(linter) == "table" and type(lint.linters[name]) == "table" then
					lint.linters[name] = vim.tbl_deep_extend("force", lint.linters[name], linter)
					if type(linter.prepend_args) == "table" then
						lint.linters[name].args = lint.linters[name].args or {}
						vim.list_extend(lint.linters[name].args, linter.prepend_args)
					end
				else
					lint.linters[name] = linter
				end
			end
			lint.linters_by_ft = opts.linters_by_ft

			function L.debounce(ms, fn)
				local timer = vim.uv.new_timer()
				return function(...)
					local argv = { ... }
					timer:start(ms, 0, function()
						timer:stop()
						vim.schedule_wrap(fn)(unpack(argv))
					end)
				end
			end

			function L.lint()
				-- Use nvim-lint's logic first:
				-- * checks if linters exist for the full filetype first
				-- * otherwise will split filetype by "." and add all those linters
				-- * this differs from conform.nvim which only uses the first filetype that has a formatter
				local names = lint._resolve_linter_by_ft(vim.bo.filetype)

				-- Create a copy of the names table to avoid modifying the original.
				names = vim.list_extend({}, names)

				-- Add fallback linters.
				if #names == 0 then
					vim.list_extend(names, lint.linters_by_ft["_"] or {})
				end

				-- Add global linters.
				vim.list_extend(names, lint.linters_by_ft["*"] or {})

				-- Filter out linters that don't exist or don't match the condition.
				local ctx = { filename = vim.api.nvim_buf_get_name(0) }
				ctx.dirname = vim.fn.fnamemodify(ctx.filename, ":h")
				names = vim.tbl_filter(function(name)
					local linter = lint.linters[name]
					if not linter then
						Utils.warn("Linter not found: " .. name, { title = "nvim-lint" })
					end
					return linter and not (type(linter) == "table" and linter.condition and not linter.condition(ctx))
				end, names)

				-- Run linters.
				if #names > 0 then
					lint.try_lint(names)
				end
			end

			vim.api.nvim_create_autocmd(opts.events, {
				group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
				callback = L.debounce(100, L.lint),
			})
		end,
	},
	{
		"which-key.nvim",
		opts = {
			specs = {
				{ "<leader>c", group = "code" },
			},
		},
	},
}

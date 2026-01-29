local M = {}

M.docshow = false

M.lz_specs = {
	{
		"blink.cmp",
		build = { useNixpkgs = "blink-cmp" },
		event = "InsertEnter",
		dependencies = {
			{
				"colorful-menu.nvim",
				source = {
					type = "github",
					repo = "colorful-menu.nvim",
					owner = "xzbdmw",
					branch = "master",
				},
				build = {
					nvimSkipModules = {
						"repro_blink",
						"repro_cmp",
					},
				},
				after = function(_, opts)
					require("colorful-menu").setup(opts)
				end,
			},
			{ "luasnip" },
			{ "lazydev.nvim" },
			{
				"blink-cmp-git",
				source = {
					type = "github",
					repo = "blink-cmp-git",
					owner = "Kaiser-Yang",
				},
			},
			{
				"cmp-vimtex",
				source = {
					type = "github",
					repo = "cmp-vimtex",
					owner = "micangl",
					branch = "master",
				},
				build = {
					nvimSkipModules = {
						"cmp_vimtex.search",
					},
				},
				dependencies = {
					{
						"blink.compat",
						source = {
							type = "github",
							repo = "blink.compat",
							owner = "Saghen",
						},
						lazy = true,
					},
				},
			},
		},
		opts = { -- snippets = {
			-- 	expand = function(snippet, _)
			-- 		return LazyVim.cmp.expand(snippet)
			-- 	end,
			--
			-- 	preset = "luasnip",
			-- },
			appearance = {
				use_nvim_cmp_as_default = false,
				nerd_font_variant = "mono",
				kind_icons = Utils.lazy_defaults.icons.kinds,
			},
			completion = {
				accept = {
					auto_brackets = {
						enabled = true,
					},
				},
				list = {
					selection = {
						preselect = true,
						auto_insert = false,
					},
				},
				trigger = {
					show_in_snippet = false,
				},

				menu = {
					winblend = 0,
					border = "rounded",
					scrollbar = false,
					scrolloff = 1,
					draw = {
						padding = 2,
						treesitter = { "lsp" },
						columns = { { "kind_icon" }, { "label", gap = 1 } },
						components = {
							label = {
								text = function(ctx)
									return require("colorful-menu").blink_components_text(ctx)
								end,
								highlight = function(ctx)
									return require("colorful-menu").blink_components_highlight(ctx)
								end,
							},
						},
					},
				},
				documentation = {
					auto_show = false,
					window = { border = "rounded" },
				},
				ghost_text = {
					enabled = true,
				},
			},
			signature = {
				enabled = true,
				trigger = {
					show_on_keyword = true,
				},
				window = {
					border = "rounded",
					show_documentation = false,
				},
			},
			sources = {
				compat = {},
				default = { "git", "lsp", "path", "snippets", "vimtex", "buffer", "lazydev" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						score_offset = 100, -- show at a higher priority than lsp
					},
					git = {
						module = "blink-cmp-git",
						name = "Git",
						enabled = function()
							return vim.tbl_contains({ 'octo", "gitcommit', "markdown" }, vim.bo.filetype)
						end,
						opts = {},
					},
					vimtex = {
						name = "vimtex",
						min_keyword_length = 2,
						module = "blink.compat.source",
						score_offset = 80,
					},
				},
			},

			cmdline = {
				enabled = false,
			},
			keymap = {
				preset = "super-tab",
				["<C-j>"] = { "select_next", "fallback" },
				["<C-k>"] = { "select_prev", "fallback" },
				["<Tab>"] = {
					function(cmp)
						if cmp.snippet_active() then
							return cmp.accept()
						else
							return cmp.select_and_accept()
						end
					end,
					"snippet_forward",
					"fallback",
				},
				["<S-Tab>"] = { "snippet_backward", "fallback" },
				["<C-b>"] = { "scroll_documentation_up", "fallback" },
				["<C-f>"] = { "scroll_documentation_down", "fallback" },
				["<C-space>"] = {
					function(cmp)
						-- Toggle signature documentation view
						if cmp.is_signature_visible() then
							cmp.hide_signature()
							require("blink.cmp.config").signature.window.show_documentation = not M.docshow
							M.docshow = not M.docshow
							vim.schedule(cmp.show_signature)
							return true
						end
					end,
					"show",
					"show_documentation",
					"hide_documentation",
				},
				["<C-e>"] = { "hide_signature", "hide", "fallback" },
				["<CR>"] = { "fallback" },
			},
		},

		after = function(_, opts)
			-- setup compat sources
			local enabled = opts.sources.default
			for _, source in ipairs(opts.sources.compat or {}) do
				opts.sources.providers[source] = vim.tbl_deep_extend(
					"force",
					{ name = source, module = "blink.compat.source" },
					opts.sources.providers[source] or {}
				)
				if type(enabled) == "table" and not vim.tbl_contains(enabled, source) then
					table.insert(enabled, source)
				end
			end

			-- add ai_accept to <Tab> key
			-- if not opts.keymap["<Tab>"] then
			-- 	if opts.keymap.preset == "super-tab" then -- super-tab
			-- 		opts.keymap["<Tab>"] = {
			-- 			require("blink.cmp.keymap.presets")["super-tab"]["<Tab>"][1],
			-- 			LazyVim.cmp.map({ "snippet_forward", "ai_accept" }),
			-- 			"fallback",
			-- 		}
			-- 	else -- other presets
			-- 		opts.keymap["<Tab>"] = {
			-- 			LazyVim.cmp.map({ "snippet_forward", "ai_accept" }),
			-- 			"fallback",
			-- 		}
			-- 	end
			-- end

			-- Unset custom prop to pass blink.cmp validation
			opts.sources.compat = nil

			-- check if we need to override symbol kinds
			-- NOTE: I can probably get rid of this
			for _, provider in pairs(opts.sources.providers or {}) do
				if provider.kind then
					local CompletionItemKind = require("blink.cmp.types").CompletionItemKind
					local kind_idx = #CompletionItemKind + 1

					CompletionItemKind[kind_idx] = provider.kind
					---@diagnostic disable-next-line: no-unknown
					CompletionItemKind[provider.kind] = kind_idx

					local transform_items = provider.transform_items
					provider.transform_items = function(ctx, items)
						items = transform_items and transform_items(ctx, items) or items
						for _, item in ipairs(items) do
							item.kind = kind_idx or item.kind
							item.kind_icon = Utils.lazy_defaults.icons.kinds[item.kind_name] or item.kind_icon or nil
						end
						return items
					end

					-- Unset custom prop to pass blink.cmp validation
					provider.kind = nil
				end
			end
			require("blink.cmp").setup(opts)
		end,
	},
}

return M

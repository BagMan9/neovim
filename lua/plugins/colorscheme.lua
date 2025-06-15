return {
	{
		"catppuccin-nvim",
		lazy = true,
		colorscheme = "catppuccin",
		after = function()
			local opts = {
				-- transparent_background = true,
				dim_inactive = {
					enabled = true,
					shade = "dark",
					percentage = 0.20,
				},
				styles = {
					booleans = { "italic" },
					keywords = { "italic" },
					types = { "italic" },
					loops = { "italic" },
				},
				integrations = {
					aerial = true,
					alpha = true,
					-- blink_cmp = {
					-- 	style = "bordered",
					-- },
					cmp = true,
					dashboard = true,

					flash = true,
					fzf = true,
					grug_far = true,
					gitsigns = true,
					headlines = true,
					illuminate = true,
					indent_blankline = { enabled = true },
					leap = true,
					lsp_trouble = true,
					mason = true,
					markdown = true,
					mini = true,
					native_lsp = {
						enabled = true,
						underlines = {
							errors = { "undercurl" },
							hints = { "undercurl" },
							warnings = { "undercurl" },
							information = { "undercurl" },
						},
					},
					navic = { enabled = true, custom_bg = "lualine" },
					neotest = true,
					neotree = true,
					noice = true,
					notify = true,
					semantic_tokens = true,
					snacks = true,
					telescope = true,
					treesitter = true,
					treesitter_context = true,
					which_key = true,
				},
				custom_highlights = function(colors)
					return {
						BlickCmpMenuBorder = { fg = colors.red },
						BlickCmpDocBorder = { fg = colors.blue },
						DiagnosticError = { style = { "bold" } },
						DiagnosticVirtualTextError = { style = { "bold" } },
						DiagnosticWarn = { style = { "bold" } },
						DiagnosticVirtualTextWarn = { style = { "bold" } },
						DiagnosticInfo = { style = { "bold" } },
						DiagnosticVirtualTextInfo = { style = { "bold" } },
						DiagnosticHint = { style = { "bold" } },
						DiagnosticVirtualTextHint = { style = { "bold" } },
					}
				end,
			}
			require("catppuccin").setup(opts)
		end,
	},
}

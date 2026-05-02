local M = {}

M.lz_specs = {
	{
		"catppuccin-nvim",
		source = {
			type = "github",
			repo = "nvim",
			owner = "catppuccin",
			branch = "main",
		},
		build = {
			nvimSkipModules = {
				"catppuccin.groups.integrations.noice",
				"catppuccin.groups.integrations.feline",
				"catppuccin.lib.vim.init",
			},
		},
		lazy = true,
		colorscheme = "catppuccin",
		after = function()
			local opts = {
				-- transparent_background = true,
				flavour = "mocha",
				dim_inactive = {
					enabled = true,
					shade = "dark",
					percentage = 0.20,
				},
				styles = {
					conditionals = { "italic" },
					booleans = { "italic" },
					keywords = { "italic" },
					types = { "italic" },
					loops = { "italic" },
				},
				default_integrations = true,
				integrations = {
					aerial = true,
					alpha = true,
					-- blink_cmp = {
					-- 	style = "bordered",
					-- },
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
					octo = true,
					semantic_tokens = true,
					snacks = true,
					telescope = true,
					treesitter = true,
					treesitter_context = true,
					which_key = true,
				},
				custom_highlights = function(colors)
					return {
						Statement = { link = "Keyword" },
						BlinkCmpMenu = { bg = colors.base },
						BlinkCmpMenuBorder = { fg = colors.overlay2 },
						BlinkCmpMenuSelection = { bg = colors.surface0 },
						-- vvv This is probably the line you want to disable
						BlinkCmpLabelMatch = { fg = "NONE", style = { "bold", "underdotted" } },
						BlinkCmpDoc = { bg = colors.base },
						BlinkCmpDocBorder = { fg = colors.red },
						BlinkCmpScrollBarThumb = { bg = colors.maroon },
						BlinkCmpSignatureHelp = { bg = colors.base },
						BlinkCmpSignatureHelpBorder = { fg = colors.mauve },
						LspInlayHint = { bg = "NONE" },
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

return M

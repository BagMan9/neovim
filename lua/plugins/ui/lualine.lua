return {
	{
		"lualine.nvim",
		dependencies = {
			{ "mcphub.nvim" },
			{ "mini.icons" },
		},
		after = function()
			local utils = Utils
			local fn = vim.fn
			local function diff_source()
				local gitsigns = vim.b.gitsigns_status_dict
				if gitsigns then
					return {
						added = gitsigns.added,
						modified = gitsigns.changed,
						removed = gitsigns.removed,
					}
				end
			end

			local function xcodebuild_device()
				if vim.g.xcodebuild_platform == "macOS" then
					return " macOS"
				end

				local deviceIcon = ""
				if vim.g.xcodebuild_platform:match("watch") then
					deviceIcon = "􀟤"
				elseif vim.g.xcodebuild_platform:match("tv") then
					deviceIcon = "􀡴 "
				elseif vim.g.xcodebuild_platform:match("vision") then
					deviceIcon = "􁎖 "
				end

				if vim.g.xcodebuild_os then
					return deviceIcon .. " " .. vim.g.xcodebuild_device_name .. " (" .. vim.g.xcodebuild_os .. ")"
				end

				return deviceIcon .. " " .. vim.g.xcodebuild_device_name
			end
			-- Gets Lines & Chars selected
			local function selectionCount()
				local isVisualMode = fn.mode():find("[Vv]")
				if not isVisualMode then
					return ""
				end
				local starts = fn.line("v")
				local ends = fn.line(".")
				local lines = starts <= ends and ends - starts + 1 or starts - ends + 1
				return " " .. tostring(lines) .. "L " .. tostring(fn.wordcount().visual_chars) .. "C"
			end
			local colors = require("catppuccin.palettes").get_palette("mocha")
			local fixed_cat = require("lualine.themes.catppuccin")
			for _, sect in ipairs({ "a", "b", "c" }) do
				fixed_cat.normal[sect].bg = "#1e1e2e"
			end
			local opts = {
				options = {
					component_separators = { left = " ", right = " " },
					section_separators = { left = " ", right = " " },
					theme = fixed_cat,
					globalstatus = true,
					disabled_filetypes = { statusline = { "dashboard", "alpha" } },
				},
				sections = {
					lualine_a = {
						{
							"mode",
							icon = "",
							color = function()
								local modes = {
									n = colors.blue,
									i = colors.green,
									v = colors.lavender,
									["␖"] = colors.blue,
									V = colors.blue,
									c = colors.pink,
									no = colors.red,
									s = colors.peach,
									S = colors.peach,
									["␓"] = colors.peach,
									ic = colors.yellow,
									R = colors.lavender,
									Rv = colors.lavender,
									cv = colors.red,
									ce = colors.red,
									r = colors.teal,
									rm = colors.teal,
									["r?"] = colors.teal,
									["!"] = colors.red,
									t = colors.red,
								}
								return { fg = modes[vim.fn.mode()], bg = "#1E1E2E" }
							end,
						},
					},
					lualine_b = {
						{
							"filetype",
							icon_only = true,
							separator = "",
							padding = { left = 1, right = 0 },
							color = { bg = "#1e1e2e" },
						},
						{ "filename", padding = { left = 0, right = 0 }, color = { bg = "#1e1e2e" } },
						{
							"diff",
							symbols = { added = "󰐖 ", modified = "󰿠 ", removed = " " },
							color = { bg = "#1E1E2E" },
						},
					},
					lualine_c = {
						-- {
						-- 	"lsp_status",
						-- 	icon = "",
						-- 	symbols = {
						-- 		done = "",
						-- 	},
						-- 	color = { fg = colors.blue, bg = "#1e1e2e" },
						-- },
						{
							"diagnostics",
							symbols = {
								error = " ",
								warn = " ",
								info = " ",
								hint = "󰝶 ",
							},
						},
					},
					lualine_x = {
						{ "' ' .. vim.g.xcodebuild_last_status", color = { fg = "Gray" } },
						{ "'󰙨 ' .. vim.g.xcodebuild_test_plan", color = { fg = "#74c7ec", bg = "#1e1e2e" } },
						{ xcodebuild_device, color = { fg = "#f9e2af", bg = "#1e1e2e" } },
						-- {
						--   moltenInfo,
						--   color = { fg = colors.yellow },
						-- },
					},
					lualine_y = {

						{ selectionCount, color = { bg = "#1E1E2E" } },
					},
					lualine_z = {
						{
							"progress",
							color = { fg = colors.blue, bg = "#1E1E2E" },
						},
						{
							"location",
							color = { fg = utils.get_hlgroup("Boolean").fg, bg = "#1e1e2e" },
						},
					},
				},

				extensions = { "toggleterm", "neo-tree", "trouble" },
			}
			require("lualine").setup(opts)
		end,
		event = "DeferredUIEnter",
	},
}

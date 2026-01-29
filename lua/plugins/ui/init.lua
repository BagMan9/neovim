local M = {}

M.lz_specs = {
	{
		"noice.nvim",
		source = {
			repo = "noice.nvim",
			type = "github",
			owner = "folke",
		},
		build = {
			nixDeps = {
				"nui-nvim",
			},
		},
		enabled = true,
		dependencies = { {
			"nui.nvim",
		} },
		opts = {
			lsp = {
				progress = {
					enabled = false,
				},
				signature = {
					auto_open = {
						enabled = false,
					},
				},
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = false,
				},
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
						},
					},
					view = "mini",
				},
			},
			presets = {
				inc_rename = true,
				bottom_search = true,
				command_palette = true,
				long_message_to_split = true,
				-- lsp_doc_border = true,
			},
		},
		after = function(_, opts)
			require("noice").setup(opts)
		end,
		event = "VeryLazy",
		keys = {
			{ "<leader>sn", "", desc = "+noice" },
			{
				"<S-Enter>",
				function()
					require("noice").redirect(vim.fn.getcmdline())
				end,
				mode = "c",
				desc = "Redirect Cmdline",
			},
			{
				"<leader>snl",
				function()
					require("noice").cmd("last")
				end,
				desc = "Noice Last Message",
			},
			{
				"<leader>snh",
				function()
					require("noice").cmd("history")
				end,
				desc = "Noice History",
			},
			{
				"<leader>sna",
				function()
					require("noice").cmd("all")
				end,
				desc = "Noice All",
			},
			{
				"<leader>snd",
				function()
					require("noice").cmd("dismiss")
				end,
				desc = "Dismiss All",
			},
			{
				"<leader>snt",
				function()
					require("noice").cmd("pick")
				end,
				desc = "Noice Picker (Telescope/FzfLua)",
			},
			{
				"<c-f>",
				function()
					if not require("noice.lsp").scroll(4) then
						return "<c-f>"
					end
				end,
				silent = true,
				expr = true,
				desc = "Scroll Forward",
				mode = { "i", "n", "s" },
			},
			{
				"<c-b>",
				function()
					if not require("noice.lsp").scroll(-4) then
						return "<c-b>"
					end
				end,
				silent = true,
				expr = true,
				desc = "Scroll Backward",
				mode = { "i", "n", "s" },
			},
		},
	},
	{
		"fidget.nvim",
		source = {
			repo = "fidget.nvim",
			type = "github",
			owner = "j-hui",
		},
		build = {
			useNixpkgs = "fidget-nvim",
		},
		event = "VeryLazy",
		opts = {
			progress = {
				display = {
					done_ttl = 1,
				},
			},
			notification = {
				window = {
					normal_hl = "String", -- Base highlight group in the notification window
					winblend = 0, -- Background color opacity in the notification window
					-- border = "rounded", -- Border around the notification window
					zindex = 45, -- Stacking priority of the notification window
					max_width = 0, -- Maximum width of the notification window
					max_height = 0, -- Maximum height of the notification window
					-- x_padding = 1, -- Padding from right edge of window boundary
					-- y_padding = 1, -- Padding from bottom edge of window boundary
					align = "bottom", -- How to align the notification window
					relative = "editor", -- What the notification window position is relative to
				},
			},
		},
		after = function(_, opts)
			require("fidget").setup(opts)
		end,
	},
}

return M

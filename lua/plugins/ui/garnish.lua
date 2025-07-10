return {
	{
		"mini.hipatterns",
		event = "VeryLazy",
		after = function()
			local opts = {
				highlighters = {
					hex_color = require("mini.hipatterns").gen_highlighter.hex_color({ priority = 2000 }),
					shorthand = {
						pattern = "()#%x%x%x()%f[^%x%w]",
						group = function(_, _, data)
							---@type string
							local match = data.full_match
							local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
							local hex_color = "#" .. r .. r .. g .. g .. b .. b

							return require("mini.hipatterns").compute_hex_color_group(hex_color, "bg")
						end,
						extmark_opts = { priority = 2000 },
					},
				},
			}
			require("mini.hipatterns").setup(opts)
		end,
	},
	{
		"mini.icons",
		lazy = true,
		init = function()
			package.preload["nvim-web-devicons"] = function()
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
		opts = {
			file = {
				[".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
				["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
			},
			filetype = {
				dotenv = { glyph = "", hl = "MiniIconsYellow" },
			},
		},
		after = function(_, opts)
			require("mini.icons").setup(opts)
		end,
	},
	{
		"nvim-navic",
		after = function()
			local opts = {
				highlight = true,
				depth_limit = 3,
			}
			require("nvim-navic").setup(opts)
		end,
		beforeAll = function()
			vim.g.navic_silence = true
			Utils.lsp.on_attach(function(client, buffer)
				---@diagnostic disable-next-line
				if client.supports_method("textDocument/documentSymbol") then
					require("nvim-navic").attach(client, buffer)
				end
			end)
		end,
	},
}

return {
	{
		"edgy.nvim",
		source = {
			repo = "edgy.nvim",
			type = "github",
			owner = "folke",
		},

		after = function()
			local opts = {
				animate = { enabled = false },
				left = {
					{
						ft = "trouble",
						filter = function(buf, win)
							local ok, inf = pcall(require("trouble")._find_last, "symbols")
							if not ok or not inf or not inf.win then
								return false
							end
							return buf == inf.win.buf or win == inf.win.win
						end,
						size = { height = 0.5 },
					},
					{
						title = "Global LSP Info",
						ft = "trouble",
						filter = function(buf, win)
							local ok, inf = pcall(require("trouble")._find_last, "useful_info")
							if not ok or not inf or not inf.win then
								return false
							end
							return buf == inf.win.buf or win == inf.win.win
						end,
						size = { height = 0.5 },
					},
				},
			}
			require("edgy").setup(opts)
		end,
		lazy = false,
	},
}

return {
	-- TODO: Could use crates-nvim
	{
		"rustaceanvim",
		source = {
			type = "github",
			repo = "rustaceanvim",
			owner = "mrcjkb",
			branch = "main",
		},
		build = {
			useNixpkgs = "rustaceanvim",
		},
		extraPackages = {
			"rustfmt",
			"clippy",
		},
		lazy = false,
		before = function(_)
			vim.g.rustaceanvim = {
				server = {
					default_settings = {
						["rust-analyzer"] = {
							files = {
								exclude = { ".direnv", "result" },
							},
						},
					},
				},
			}
		end,
	},
	-- {
	-- 	"crates.nvim",
	-- 	source = {
	-- 		type = "github",
	-- 		repo = "crates.nvim",
	-- 		owner = "saecki",
	-- 		branch = "master",
	-- 	},
	-- 	build = {
	-- 		useNixpkgs = "crates-nvim",
	-- 	},
	-- 	after = function(_, opts)
	-- 		require("crates").setup()
	-- 	end,
	-- },
}

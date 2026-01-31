return {
	{
		"rustaceanvim",
		source = {
			type = "github",
			repo = "rustaceanvim",
			owner = "mrcjkb",
			branch = "master",
		},
		build = {
			useNixpkgs = "rustaceanvim",
		},
		extraPackages = {
			"rustfmt",
			"clippy",
		},
		lazy = false,
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

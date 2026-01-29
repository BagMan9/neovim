return {
	{
		"rustaceanvim",
		source = {
			type = "github",
			repo = "rustaceanvim",
			owner = "mrcjkb",
			branch = "master",
		},
		extraPackages = {
			"rustfmt",
			"clippy",
		},
		lazy = false,
	},
}

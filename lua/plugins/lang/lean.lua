return {
	"lean.nvim",
	build = {
		useNixpkgs = "lean-nvim",
	},
	event = { "BufReadPre *.lean", "BufNewFile *.lean" },
	opts = {
		mappings = true,
	},
	after = function(_, opts)
		require("lean").setup(opts)
	end,
}

return {
	-- TODO: Setup avante
	-- {
	-- 	"avante.nvim",
	-- 	before = function()
	-- 		require("lz.n").trigger_load("render-markdown.nvim")
	-- 	end,
	-- 	after = function()
	-- 		local opts = {}
	-- 		require("avante").setup(opts)
	-- 	end,
	-- },
	{
		"render-markdown.nvim",
		ft = { "md", "Avante" },
		after = function()
			local opts = {
				file_types = { "markdown", "Avante" },
				completion = { lsp = { enabled = true } },
			}
			require("render-markdown").setup(opts)
		end,
	},
}

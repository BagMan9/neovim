return {
	{
		"kulala.nvim",
		keys = {
			{ "<leader>Rs", desc = "Send request" },
			{ "<leader>Ra", desc = "Send all requests" },
			{ "<leader>Rb", desc = "Open scratchpad" },
		},
		ft = { "http", "rest" },
		after = function()
			require("kulala").setup({
				global_keymaps = true,
				kulala_keymaps = true,
				ui = {
					icons = {
						inlay = {
							loading = "",
							done = "",
							error = "",
						},
					},
				},
			})
		end,
	},
}

return {
	{
		"auto-session",
		lazy = false,
		after = function()
			local opts = {
				purge_after_minutes = 10080,
				session_lens = {
					picker_opts = {
						preset = "dropdown",
						preview = false,
					},
				},
			}
			require("auto-session").setup(opts)
		end,
	},
}

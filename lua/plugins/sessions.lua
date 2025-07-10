local M = {}

M.lz_specs = {
	{
		"auto-session",
		lazy = false,
		opts = {
			purge_after_minutes = 10080,
			session_lens = {
				picker_opts = {
					preset = "dropdown",
					preview = false,
				},
			},
		},
		after = function(_, opts)
			require("auto-session").setup(opts)
		end,
	},
}

return M

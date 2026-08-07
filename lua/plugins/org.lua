return {
	{
		"orgmode",
		event = "VeryLazy",
		build = {
			useNixpkgs = "orgmode",
		},
		opts = {
			org_agenda_files = "~/org/**/*",
			org_default_notes_file = "~/org/refile.org",
		},
		after = function(_, opts)
			require("orgmode").setup(opts)
			vim.lsp.enable("org")
		end,
	},
}

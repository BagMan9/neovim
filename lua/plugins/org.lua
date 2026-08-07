return {
	{
		"orgmode",
		event = "VeryLazy",
		ft = "org",
		build = {
			useNixpkgs = "orgmode",
		},
		opts = {
			org_agenda_files = "~/org/**/*",
			org_default_notes_file = "~/org/refile.org",
			org_todo_keywords = {
				"IDEA(i)",
				"EXPLORING(e)",
				"PLANNED(p)",
				"TODO(t)",
				"NEXT(n)",
				"WAIT(w@/!)",
				"|",
				"DONE(d!)",
				"SHELVED(v)",
			},
			org_todo_repeat_to_state = "TODO",
			org_hide_leading_stars = true,
			calendar_week_start_day = 0,
		},
		after = function(_, opts)
			require("orgmode").setup(opts)
			vim.lsp.enable("org")
			-- orgmode only registers its treesitter parser (`org`) during setup().
			-- Any org buffers opened before setup ran (startup / session restore)
			-- had their ftplugin call vim.treesitter.start() while the parser was
			-- still unregistered, so they silently fell back to legacy syntax
			-- (only orgHeadline, no @org.* captures). Restart them now.
			for _, buf in ipairs(vim.api.nvim_list_bufs()) do
				if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "org" then
					pcall(vim.treesitter.start, buf)
				end
			end
		end,
	},
}

local M = {}

M.lz_specs = {
	{
		"octo.nvim",
		cmd = "Octo",
		event = "BufReadCmd octo://",
		dependencies = { { "plenary.nvim" } },
		after = function()
			local opts = {
				enable_builtin = true,
				default_to_projects_v2 = true,
				default_merge_method = "squash",
				picker = "snacks",
			}
			require("octo").setup(opts)
		end,
		keys = {
			{ "<leader>gi", "<cmd>Octo issue list<CR>", desc = "List Issues (Octo)" },
			{ "<leader>gI", "<cmd>Octo issue search<CR>", desc = "Search Issues (Octo)" },
			{ "<leader>gp", "<cmd>Octo pr list<CR>", desc = "List PRs (Octo)" },
			{ "<leader>gP", "<cmd>Octo pr search<CR>", desc = "Search PRs (Octo)" },
			{ "<leader>gr", "<cmd>Octo repo list<CR>", desc = "List Repos (Octo)" },
			{ "<leader>gS", "<cmd>Octo search<CR>", desc = "Search (Octo)" },
			{ "<localleader>a", "", desc = "+assignee (Octo)", ft = "octo" },
			{ "<localleader>c", "", desc = "+comment/code (Octo)", ft = "octo" },
			{ "<localleader>l", "", desc = "+label (Octo)", ft = "octo" },
			{ "<localleader>i", "", desc = "+issue (Octo)", ft = "octo" },
			{ "<localleader>r", "", desc = "+react (Octo)", ft = "octo" },
			{ "<localleader>p", "", desc = "+pr (Octo)", ft = "octo" },
			{ "<localleader>pr", "", desc = "+rebase (Octo)", ft = "octo" },
			{ "<localleader>ps", "", desc = "+squash (Octo)", ft = "octo" },
			{ "<localleader>v", "", desc = "+review (Octo)", ft = "octo" },
			{ "<localleader>g", "", desc = "+goto_issue (Octo)", ft = "octo" },
			{ "@", "@<C-x><C-o>", mode = "i", ft = "octo", silent = true },
			{ "#", "#<C-x><C-o>", mode = "i", ft = "octo", silent = true },
		},
	},
	{
		"gitsigns.nvim",
		lazy = false,
		opts = {
			debug_mode = true,
			signs = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
				untracked = { text = "▎" },
			},
			signs_staged = {
				add = { text = "▎" },
				change = { text = "▎" },
				delete = { text = "" },
				topdelete = { text = "" },
				changedelete = { text = "▎" },
			},
			on_attach = function(buffer)
				local gs = package.loaded.gitsigns

				local function map(mode, l, r, desc)
					vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
				end

      -- stylua: ignore start
      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk("next")
        end
      end, "Next Hunk")
      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end, "Prev Hunk")
      map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
      map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
      map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
      map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
      map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
      map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
      map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
      map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
      map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
      map("n", "<leader>ghB", function() gs.blame() end, "Blame Buffer")
      map("n", "<leader>ghd", gs.diffthis, "Diff This")
      map("n", "<leader>ghD", function() gs.diffthis("~") end, "Diff This ~")
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
			end,
		},
		after = function(_, opts)
			require("gitsigns").setup(opts)
		end,
	},
	{
		-- NOTE: Don't forget about me! Useful for work!
		"gitlinker.nvim",
		keys = {
			{
				"<leader>gy",
				-- function()
				-- 	require("gitlinker").setup()
				-- end,
				mode = { "n", "v" },
				desc = "Create links to current line(s)",
			},
		},
		after = function()
			require("gitlinker").setup()
		end,
	},
	{
		"snacks.nvim",
		keys = {
			{
				"<leader>gd",
				function()
					require("snacks").picker.git_diff()
				end,
				desc = "Git Diff (hunks)",
			},
			{
				"<leader>gs",
				function()
					require("snacks").picker.git_status()
				end,
				desc = "Git Status",
			},
			{
				"<leader>gS",
				function()
					require("snacks").picker.git_stash()
				end,
				desc = "Git Stash",
			},
		},
	},
	{
		"which-key.nvim",
		opts = {
			specs = {
				{ "<leader>g", group = "git" },
				{ "<leader>gh", group = "hunks" },
			},
		},
	},
}

return M

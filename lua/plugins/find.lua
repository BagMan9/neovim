return {
	{
		"whichkey.nvim",
		opts = {
			specs = {
				{ "<leader>f", group = "file/find" },
				{ "<leader>s", group = "search/snips" },
			},
		},
	},
	{
		"snacks.nvim",
		opts = {
			picker = {
				win = {
					input = {
						keys = {
							["<a-c>"] = {
								"toggle_cwd",
								mode = { "n", "i" },
							},
							["<a-t>"] = {
								"trouble_open",
								mode = { "n", "i" },
							},
						},
					},
				},
			},
		},
		keys = {
			{
				"<leader>,",
				function()
					require("snacks").picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>/",
				function()
					require("snacks").picker.open("grep")
				end,
				desc = "Grep (Root Dir)",
			},
			{
				"<leader>:",
				function()
					require("snacks").picker.command_history()
				end,
				desc = "Command History",
			},
			{
				"<leader><space>",
				function()
					require("snacks").picker.files()
				end,
				desc = "Find Files (Root Dir)",
			},
			{
				"<leader>n",
				function()
					require("snacks").picker.notifications()
				end,
				desc = "Notification History",
			},
			-- find
			{
				"<leader>fb",
				function()
					require("snacks").picker.buffers()
				end,
				desc = "Buffers",
			},
			{
				"<leader>fB",
				function()
					require("snacks").picker.buffers({ hidden = true, nofile = true })
				end,
				desc = "Buffers (all)",
			},
			{
				"<leader>fc",
				function()
					require("snacks").picker.files({ cwd = vim.fn.stdpath("config") })
				end,
				desc = "Find Config File",
			},
			{
				"<leader>ff",
				function()
					require("snacks").picker.files()
				end,
				desc = "Find Files (Root Dir)",
			},
			{
				"<leader>fF",
				function()
					require("snacks").picker.files({ root = false })
				end,
				desc = "Find Files (cwd)",
			},
			{
				"<leader>fg",
				function()
					require("snacks").picker.git_files()
				end,
				desc = "Find Files (git-files)",
			},
			{
				"<leader>fr",
				function()
					require("snacks").picker.open("oldfiles")
				end,
				desc = "Recent",
			},
			{
				"<leader>fR",
				function()
					require("snacks").picker.recent({ filter = { cwd = true } })
				end,
				desc = "Recent (cwd)",
			},
			{
				"<leader>fp",
				function()
					require("snacks").picker.projects()
				end,
				desc = "Projects",
			},

			-- Grep
			{
				"<leader>sb",
				function()
					require("snacks").picker.lines()
				end,
				desc = "Buffer Lines",
			},
			{
				"<leader>sB",
				function()
					require("snacks").picker.grep_buffers()
				end,
				desc = "Grep Open Buffers",
			},
			{
				"<leader>sg",
				function()
					require("snacks").picker.grep()
				end,
				desc = "Grep (Root Dir)",
			},
			{
				"<leader>sG",
				function()
					require("snacks").picker.grep({ root = false })
				end,
				desc = "Grep (cwd)",
			},
			{
				"<leader>sp",
				function()
					require("snacks").picker.lazy()
				end,
				desc = "Search for Plugin Spec",
			},
			{
				"<leader>sw",
				function()
					require("snacks").picker.open("grep_word")
				end,
				desc = "Visual selection or word (Root Dir)",
				mode = { "n", "x" },
			},
			{
				"<leader>sW",
				function()
					require("snacks").picker.open("grep_word", { root = false })
				end,
				desc = "Visual selection or word (cwd)",
				mode = { "n", "x" },
			},
			-- search
			{
				'<leader>s"',
				function()
					require("snacks").picker.registers()
				end,
				desc = "Registers",
			},
			{
				"<leader>s/",
				function()
					require("snacks").picker.search_history()
				end,
				desc = "Search History",
			},
			{
				"<leader>sa",
				function()
					require("snacks").picker.autocmds()
				end,
				desc = "Autocmds",
			},
			{
				"<leader>sc",
				function()
					require("snacks").picker.command_history()
				end,
				desc = "Command History",
			},
			{
				"<leader>sC",
				function()
					require("snacks").picker.commands()
				end,
				desc = "Commands",
			},
			{
				"<leader>sd",
				function()
					require("snacks").picker.diagnostics()
				end,
				desc = "Diagnostics",
			},
			{
				"<leader>sD",
				function()
					require("snacks").picker.diagnostics_buffer()
				end,
				desc = "Buffer Diagnostics",
			},
			{
				"<leader>sh",
				function()
					require("snacks").picker.help()
				end,
				desc = "Help Pages",
			},
			{
				"<leader>sH",
				function()
					require("snacks").picker.highlights()
				end,
				desc = "Highlights",
			},
			{
				"<leader>si",
				function()
					require("snacks").picker.icons()
				end,
				desc = "Icons",
			},
			{
				"<leader>sj",
				function()
					require("snacks").picker.jumps()
				end,
				desc = "Jumps",
			},
			{
				"<leader>sk",
				function()
					require("snacks").picker.keymaps()
				end,
				desc = "Keymaps",
			},
			{
				"<leader>sl",
				function()
					require("snacks").picker.loclist()
				end,
				desc = "Location List",
			},
			{
				"<leader>sM",
				function()
					require("snacks").picker.man()
				end,
				desc = "Man Pages",
			},
			{
				"<leader>sm",
				function()
					require("snacks").picker.marks()
				end,
				desc = "Marks",
			},
			{
				"<leader>sR",
				function()
					require("snacks").picker.resume()
				end,
				desc = "Resume",
			},
			{
				"<leader>sq",
				function()
					require("snacks").picker.qflist()
				end,
				desc = "Quickfix List",
			},
			{
				"<leader>su",
				function()
					require("snacks").picker.undo()
				end,
				desc = "Undotree",
			},
		},
	},
}

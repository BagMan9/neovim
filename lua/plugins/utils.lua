return {
	{
		"mini.pairs",
		event = "DeferredUIEnter",
		after = function()
			local opts = {
				modes = { insert = true, command = true, terminal = false },
				-- skip autopair when next character is one of these
				skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
				-- skip autopair when the cursor is inside these treesitter nodes
				skip_ts = { "string" },
				-- skip autopair when next character is closing pair
				-- and there are more closing pairs than opening pairs
				skip_unbalanced = true,
				-- better deal with markdown code blocks
				markdown = true,
			}
			--PREVIOUS CONFIG
			Utils.pairs(opts)
		end,
	},
	{
		"which-key.nvim",
		event = "DeferredUIEnter",
		after = function()
			local opts = {
				preset = "helix",
				defaults = {},
				spec = {
					{
						mode = { "n", "v" },
						{ "<leader><tab>", group = "tabs" },
						{ "<leader>c", group = "code" },
						{ "<leader>d", group = "debug" },
						{ "<leader>dp", group = "profiler" },
						{ "<leader>f", group = "file/find" },
						{ "<leader>g", group = "git" },
						{ "<leader>gh", group = "hunks" },
						{ "<leader>q", group = "quit/session" },
						{ "<leader>s", group = "search" },
						{ "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
						{ "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
						{ "[", group = "prev" },
						{ "]", group = "next" },
						{ "g", group = "goto" },
						{ "gs", group = "surround" },
						{ "z", group = "fold" },
						{ "<BS>", desc = "Decrement Selection", mode = "x" },
						{ "<c-space>", desc = "Increment Selection", mode = { "x", "n" } },
						{
							"<leader>b",
							group = "buffer",
							expand = function()
								return require("which-key.extras").expand.buf()
							end,
						},
						{
							"<leader>w",
							group = "windows",
							proxy = "<c-w>",
							expand = function()
								return require("which-key.extras").expand.win()
							end,
						},
						-- better descriptions
						{ "gx", desc = "Open with system app" },
					},
				}, --MERGE POINT
			}
			--PREVIOUS CONFIG
			require("which-key").setup(opts)
		end,
		keys = {
			{
				"<leader>?",
				function()
					require("which-key").show({ global = false })
				end,
				desc = "Buffer Keymaps (which-key)",
			},
			{
				"<c-w><space>",
				function()
					require("which-key").show({ keys = "<c-w>", loop = true })
				end,
				desc = "Window Hydra Mode (which-key)",
			},
		},
	},
	{
		"gitsigns.nvim",
		event = "User LazyFile",
		after = function()
			local opts = {
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
			}
			require("gitsigns").setup(opts)
		end,
	},
	{
		"mini.comment",
		event = "User LazyFile",
	},
	{
		"yanky.nvim",
		event = "User LazyFile",
		after = function()
			local opts = {
				highlight = { timer = 150 },
			}
			require("yanky").setup(opts)
		end,
		keys = {
			{
				"<leader>p",
				function()
					vim.cmd([[YankyRingHistory]])
				end,
				mode = { "n", "x" },
				desc = "Open Yank History",
			},
			{ "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank Text" },
			{ "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put Text After Cursor" },
			{ "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Cursor" },
			{ "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" }, desc = "Put Text After Selection" },
			{ "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Selection" },
			{ "[y", "<Plug>(YankyCycleForward)", desc = "Cycle Forward Through Yank History" },
			{ "]y", "<Plug>(YankyCycleBackward)", desc = "Cycle Backward Through Yank History" },
			{ "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put Indented After Cursor (Linewise)" },
			{ "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put Indented Before Cursor (Linewise)" },
			{ "]P", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put Indented After Cursor (Linewise)" },
			{ "[P", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put Indented Before Cursor (Linewise)" },
			{ ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and Indent Right" },
			{ "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and Indent Left" },
			{ ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put Before and Indent Right" },
			{ "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put Before and Indent Left" },
			{ "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put After Applying a Filter" },
			{ "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put Before Applying a Filter" },
		},
	},

	{
		"snacks.nvim",
		lazy = false,
		after = function()
			vim.g.snacks_animate = false
			local opts = {
				words = { enabled = true },
				explorer = {}, --MERGE POINT

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
				actions = {
					---@param p snacks.Picker
					toggle_cwd = function(p)
						local root = require("my.root").get({ buf = p.input.filter.current_buf, normalize = true })
						local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
						local current = p:cwd()
						p:set_cwd(current == root and cwd or root)
						p:find()
					end,
					trouble_open = function(...)
						return require("trouble.sources.snacks").actions.trouble_open.action(...)
					end,
				},
				bigfile = { enabled = false },
				indent = { enabled = false, scope = { enabled = false } },
				input = { enabled = false },
				notifier = { enabled = true },
				quickfile = { enabled = false },
				scroll = { enabled = false },
				statuscolumn = { enabled = false },
				toggle = { map = vim.keymap.set },
				dashboard = {
					enabled = true,
					preset = {
						pick = function(cmd, opts)
							return require("snacks").picker.pick(cmd, opts)
						end,
						header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝]],
          -- stylua: ignore
          ---@type snacks.dashboard.Item[]
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua require(\"snacks\").dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua require(\"snacks\").dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua require(\"snacks\").dashboard.pick('oldfiles')" },
            { icon = " ", key = "c", desc = "Config", action = ":lua require(\"snacks\").dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
					},
					sections = {
						{ section = "header" },
						{ section = "keys", gap = 1, padding = 1 },
					},
				}, --MERGE POINT
			}
			require("snacks").setup(opts)
		end,
		keys = {
			{
				"<leader>fe",
				function()
					require("snacks").explorer({ cwd = require("my.root").get() })
				end,
				desc = "Explorer Snacks (root dir)",
			},
			{
				"<leader>fE",
				function()
					require("snacks").explorer()
				end,
				desc = "Explorer Snacks (cwd)",
			},
			{ "<leader>e", "<leader>fe", desc = "Explorer Snacks (root dir)", remap = true },
			{ "<leader>E", "<leader>fE", desc = "Explorer Snacks (cwd)", remap = true },
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
			-- git
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
			-- ui
			{
				"<leader>uC",
				function()
					require("snacks").picker.colorschemes()
				end,
				desc = "Colorschemes",
			},
		},
	},
	{
		"mini.hipatterns",
		event = "DeferredUIEnter",
		after = function()
			local opts = {
				highlighters = {
					hex_color = require("mini.hipatterns").gen_highlighter.hex_color({ priority = 2000 }),
					shorthand = {
						pattern = "()#%x%x%x()%f[^%x%w]",
						group = function(_, _, data)
							---@type string
							local match = data.full_match
							local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
							local hex_color = "#" .. r .. r .. g .. g .. b .. b

							return MiniHipatterns.compute_hex_color_group(hex_color, "bg")
						end,
						extmark_opts = { priority = 2000 },
					},
				},
			}
			require("mini.hipatterns").setup(opts)
		end,
	},
	{
		"persistence.nvim",
		event = "BufReadPre",
		after = function()
			local opts = {
        need = 2,
        branch = true
      }
		end,
	},
	{
		"nui.nvim",
	},
	{
		"plenary.nvim",
	},
}

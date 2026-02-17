local M = {}

M.lz_specs = {
	{
		"which-key.nvim",
		event = "VeryLazy",
		build = { useNixpkgs = "which-key-nvim" },
		-- source = {
		--   type = "github",
		-- }
		opts = {
			preset = "helix",
			defaults = {},
			spec = {
				{
					mode = { "n", "v" },
					{ "<leader>a", group = "+ai" },
					{ "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫 ", color = "green" } },
					{ "<leader>c", group = "code" },
					{ "<localleader>x", group = "xcode" },
					{ "<leader>f", group = "file/find" },
					{ "<leader>d", group = "debug" },
					{ "<leader>dp", group = "profiler" },
					{ "<leader>s", group = "search/snips" },
					{ "<leader><tab>", group = "tabs" },
					{ "<leader>q", group = "quit/session" },
					{ "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },
					{ "[", group = "prev" },
					{ "]", group = "next" },
					{ "g", group = "goto" },
					{ "<leader>g", group = "git" },
					{ "<leader>gh", group = "hunks" },
					-- { "gs", group = "surround" },
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
			},
		},
		after = function(_, opts)
			require("which-key").setup(opts)
			vim.schedule(function()
				Utils.ai_whichkey(opts)
			end)
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
}

return M

local M = {}

M.lz_specs = {
	{
		"snacks.nvim",
		lazy = false,
		opts = {
			styles = {},
			words = { enabled = true },
			actions = {
				toggle_cwd = function(p)
					local root = Utils.root.get({ buf = p.input.filter.current_buf, normalize = true })
					---@diagnostic disable-next-line: undefined-field
					local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
					local current = p:cwd()
					p:set_cwd(current == root and cwd or root)
					p:find()
				end,
				trouble_open = function(...)
					return require("trouble.sources.snacks").actions.trouble_open.action(...)
				end,
			},
			notifier = { enabled = true },
			bigfile = { enabled = true },
			toggle = { map = vim.keymap.set },

			input = { enabled = false },
			quickfile = { enabled = false },
			scroll = { enabled = false },
			indent = { enabled = false, scope = { enabled = false } },
			statuscolumn = { enabled = false },
			explorer = { enabled = false },
		},
		after = function(_, opts)
			vim.g.snacks_animate = false
			require("snacks").setup(opts)
		end,
	},
}

return M

local M = {}

M.lz_specs = {
	{
		"nvim-treesitter-context",
		lazy = false,
		event = "LazyFile",
		opts = {
			max_lines = 5,
		},
	},
	{
		"nvim-treesitter",
		opts = {
			highlight = { enable = true },
			indent = { enable = true },
			enable = true,
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
			textobjects = {
				move = {
					enable = true,
					goto_next_start = {
						["]f"] = "@function.outer",
						["]c"] = "@class.outer",
						["]a"] = "@parameter.inner",
					},
					goto_next_end = {
						["]F"] = "@function.outer",
						["]C"] = "@class.outer",
						["]A"] = "@parameter.inner",
					},
					goto_previous_start = {
						["[f"] = "@function.outer",
						["[c"] = "@class.outer",
						["[a"] = "@parameter.inner",
					},
					goto_previous_end = {
						["[F"] = "@function.outer",
						["[C"] = "@class.outer",
						["[A"] = "@parameter.inner",
					},
				},
			},
		},
		after = function(_, opts)
			local ts = require("nvim-treesitter")

			-- setup() now only takes install_dir option
			-- ts.setup() -- or just ts.setup() if default

			if opts.ensure_installed then
				ts.install(opts.ensure_installed)
			end

			-- Enable highlighting via autocommand
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(ev)
					pcall(vim.treesitter.start, ev.buf)
				end,
			})
			-- If you used indent = { enable = true }:
			vim.api.nvim_create_autocmd("FileType", {
				callback = function()
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end,
			})
		end,
		extension = { rasi = "rasi", rofi = "rasi", wofi = "rasi" },
		filename = {
			["vifmrc"] = "vim",
		},
		pattern = {
			[".*/waybar/config"] = "jsonc",
			[".*/mako/config"] = "dosini",
			[".*/kitty/.+%.conf"] = "kitty",
			[".*/hypr/.+%.conf"] = "hyprlang",
			["%.env%.[%w_.-]+"] = "sh",
		},
		event = "LazyFile",
		lazy = false,
	},
	{
		"nvim-treesitter-textobjects",
		event = "User LazyFile",
		enabled = true,
	},
	{
		"nvim-ts-autotag",
		event = "User LazyFile",
	},
	{
		"nvim-ts-context-commentstring",
		lazy = true,
	},
	-- {
	-- 	"ts-comments.nvim",
	-- 	event = "VeryLazy",
	-- },
}

return M

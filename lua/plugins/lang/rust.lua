-- Run a :RustLsp subcommand; accepts extra words as command args.
local function rustlsp(...)
	local args = { ... }
	return function()
		vim.cmd.RustLsp(#args == 1 and args[1] or args)
	end
end

-- Run :RustLsp! <sub> (the bang reruns the last target).
local function rustlsp_last(sub)
	return function()
		vim.cmd.RustLsp({ sub, bang = true })
	end
end

-- Debug entry points must force-load the dap stack first: rustaceanvim only
-- require()s nvim-dap, which bypasses the lzl `after` hooks that register the
-- dap-ui auto-open listeners, signs, virtual text, and the session keymaps.
local function rustlsp_debug(bang)
	return function()
		require("lz.n").trigger_load("nvim-dap")
		vim.cmd.RustLsp(bang and { "debuggables", bang = true } or "debuggables")
	end
end

return {
	{
		-- rust-analyzer is started by rustaceanvim, not lspconfig. We register
		-- it here with `enabled = false` purely so the lsp keymap pipeline picks
		-- up these buffer-local keys on attach (the setup loop bails on
		-- enabled == false before it would touch the server).
		"nvim-lspconfig",
		opts = {
			servers = {
				["rust-analyzer"] = {
					enabled = false,
					keys = {
						-- 1. Better versions of generic actions (shadow globals)
						{ "<leader>cd", rustlsp("renderDiagnostic", "current"), desc = "Render Diagnostic (rust)" },
						{ "<leader>ca", rustlsp("codeAction"), mode = { "n", "x" }, desc = "Code Action (grouped)" },
						{ "K", rustlsp("hover", "actions"), desc = "Hover Actions (rust)" },

						-- 2. Smarter versions of generic motions/edits (shadow globals)
						{ "<A-j>", rustlsp("moveItem", "down"), desc = "Move Item Down" },
						{ "<A-k>", rustlsp("moveItem", "up"), desc = "Move Item Up" },
						{ "J", rustlsp("joinLines"), mode = { "n", "x" }, desc = "Join Lines (rust)" },
						-- 3. Rust-specific tools under <localleader>
						{
							"<localleader><localleader>",
							"<Plug>RustHoverAction",
							mode = "n",
							desc = "Rust Hover Shortcut",
						},
						{ "<localleader>r", rustlsp("runnables"), desc = "Runnables" },
						{ "<localleader>R", rustlsp_last("runnables"), desc = "Runnables (rerun last)" },
						{ "<localleader>t", rustlsp("testables"), desc = "Testables" },
						{ "<localleader>T", rustlsp_last("testables"), desc = "Testables (rerun last)" },
						{ "<localleader>d", rustlsp_debug(false), desc = "Debuggables" },
						{ "<localleader>D", rustlsp_debug(true), desc = "Debuggables (rerun last)" },
						{ "<localleader>e", rustlsp("explainError", "current"), desc = "Explain Error" },
						{ "<localleader>m", rustlsp("expandMacro"), desc = "Expand Macro" },
						{ "<localleader>p", rustlsp("parentModule"), desc = "Parent Module" },
						{ "<localleader>c", rustlsp("openCargo"), desc = "Open Cargo.toml" },
						{ "<localleader>o", rustlsp("openDocs"), desc = "Open External Docs" },
					},
				},
			},
		},
	},
	{
		"rustaceanvim",
		source = {
			type = "github",
			repo = "rustaceanvim",
			owner = "mrcjkb",
			branch = "main",
		},
		build = {
			useNixpkgs = "rustaceanvim",
		},
		extraPackages = {
			"rustfmt",
			"clippy",
		},
		dependencies = {
			{ "nvim-dap" },
		},
		lazy = false,
		before = function(_)
			vim.g.rustaceanvim = {
				tools = {
					-- Run tests in the background and surface failures as
					-- diagnostics. Replaces the test-target compile diagnostics
					-- we give up by disabling check.allTargets below.
					test_executor = "background",
				},
				server = {
					default_settings = {
						["rust-analyzer"] = {
							files = {
								exclude = { ".direnv", "result" },
							},
							-- Keeps files readable
							semanticHighlighting = { doc = { comment = { inject = { enable = false } } } },
							-- Don't check all targets: avoids the same file being
							-- compiled under lib + test + bin, which produced
							-- duplicate diagnostics (and duplicate quickfixes).
							check = {
								allTargets = false,
							},
						},
					},
				},
			}
		end,
	},
	{
		"crates.nvim",
		source = {
			type = "github",
			repo = "crates.nvim",
			owner = "saecki",
			branch = "main",
		},
		build = {
			useNixpkgs = "crates-nvim",
		},
		opts = {},
		after = function(_, opts)
			require("crates").setup(opts)
		end,
	},
}

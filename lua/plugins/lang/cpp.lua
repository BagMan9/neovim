return {
	{
		"nvim-lspconfig",
		opts = {
			servers = {
				clangd = {
					keys = {
						-- MAYBE: Setup more clangd-extensions stuff
						{
							"<leader>ch",
							function()
								return "<cmd>ClangdSwitchSourceHeader<cr>"
							end,
							desc = "Switch Source/Header (C/C++)",
						},
					},
					root_dir = function(fname)
						return require("lspconfig.util").root_pattern(
							"Makefile",
							"configure.ac",
							"configure.in",
							"config.h.in",
							"meson.build",
							"meson_options.txt",
							"build.ninja"
						)(fname) or require("lspconfig.util").root_pattern(
							"compile_commands.json",
							"compile_flags.txt"
						)(fname) or require("lspconfig.util").find_git_ancestor(fname)
					end,
					capabilities = {
						offsetEncoding = { "utf-16" },
					},
					cmd = {
						"clangd",
						"--background-index",
						"--clang-tidy",
						"--header-insertion=iwyu",
						"--completion-style=detailed",
						"--function-arg-placeholders",
						"--fallback-style=llvm",
					},
					init_options = {
						usePlaceholders = true,
						completeUnimported = true,
						clangdFileStatus = true,
					},
				},
			},
		},
	},
	{
		"clangd_extensions.nvim",
		lazy = true,
		cmd = {
			"ClangdSymbolInfo",
			"ClangdTypeHierarchy",
			"ClangdMemoryUsage",
			"ClangdAST",
			"ClangdSwitchSourceHeader",
		},
	},
}

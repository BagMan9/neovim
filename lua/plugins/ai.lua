return {
	--TODO: Setup MCPHub Nvim (need to package myself)
	--Setup with/avante
	--Setup nix mcp server
	--
	--Separately, think about tmux-split setup with commandline at bottom and stdout on top for remote stuff. Auto send stdout to neovim, send cmdline to neovim for editing, etc
	{
		"avante.nvim",
		before = function()
			require("lz.n").trigger_load("render-markdown.nvim")
		end,
		event = "User LazyFile",
		after = function()
			local opts = {
				--TODO: Figure out if I can integrate gemini for free w/aistudio
				providers = {
					-- TODO: Add reasoning https://openrouter.ai/docs/use-cases/reasoning-tokens
					or_claude = {
						__inherited_from = "openai",
						endpoint = "https://openrouter.ai/api/v1",
						model = "anthropic/claude-sonnet-4",
						api_key_name = "OPENROUTER_API_KEY",
					},
					or_r1 = {
						__inherited_from = "openai",
						endpoint = "https://openrouter.ai/api/v1",
						model = "deepseek/deepseek-r1",
						api_key_name = "OPENROUTER_API_KEY",
					},
					or_v3 = {
						__inherited_from = "openai",
						endpoint = "https://openrouter.ai/api/v1",
						model = "deepseek/deepseek-v3-0324",
						api_key_name = "OPENROUTER_API_KEY",
					},
					or_gem_2_5_pro = {
						__inherited_from = "openai",
						endpoint = "https://openrouter.ai/api/v1",
						model = "google/gemini-2.5-pro",
						api_key_name = "OPENROUTER_API_KEY",
					},
				},

				provider = "or_v3",
				--TODO: Check out dual boost mode
				--TODO: Setup cmp suggestions
			}
			require("avante").setup(opts)
		end,
	},
	{
		"render-markdown.nvim",
		ft = { "md", "Avante" },
		after = function()
			local opts = {
				file_types = { "markdown", "Avante" },
				completion = { lsp = { enabled = true } },
			}
			require("render-markdown").setup(opts)
		end,
	},
}

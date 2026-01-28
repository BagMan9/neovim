-- TODO: Re do all AI config, disabling for now
local M = {}
local openrouter_secret = "cmd:cat /run/agenix/ai-key"

M.lz_specs = {
	-- 	{
	-- 		"avante.nvim",
	-- 		dependencies = {
	-- 			{
	-- 				"render-markdown.nvim",
	-- 				ft = { "md", "Avante" },
	-- 				after = function()
	-- 					local opts = {
	-- 						file_types = { "markdown", "Avante" },
	-- 						completion = { lsp = { enabled = true } },
	-- 					}
	-- 					require("render-markdown").setup(opts)
	-- 				end,
	-- 			},
	-- 		},
	-- 		event = "User LazyFile",
	-- 		after = function()
	-- 			require("img-clip").setup({ default = { download_images = false } })
	-- 			local opts = {
	-- 				system_prompt = function()
	-- 					local hub = require("mcphub").get_hub_instance()
	-- 					return hub and hub:get_active_servers_prompt() or ""
	-- 				end,
	-- 				custom_tools = function()
	-- 					return {
	-- 						require("mcphub.extensions.avante").mcp_tool(),
	-- 					}
	-- 				end,
	-- 				providers = {
	-- 					or_claude = {
	-- 						__inherited_from = "openai",
	-- 						endpoint = "https://openrouter.ai/api/v1",
	-- 						model = "anthropic/claude-sonnet-4",
	-- 						api_key_name = openrouter_secret,
	-- 					},
	-- 					or_r1 = {
	-- 						__inherited_from = "openai",
	-- 						endpoint = "https://openrouter.ai/api/v1",
	-- 						model = "deepseek/deepseek-r1",
	-- 						api_key_name = openrouter_secret,
	-- 					},
	-- 					or_v3 = {
	-- 						__inherited_from = "openai",
	-- 						endpoint = "https://openrouter.ai/api/v1",
	-- 						model = "deepseek/deepseek-chat-v3-0324",
	-- 						api_key_name = openrouter_secret,
	-- 					},
	-- 					or_gem_2_5_pro = {
	-- 						__inherited_from = "openai",
	-- 						endpoint = "https://openrouter.ai/api/v1",
	-- 						model = "google/gemini-2.5-pro",
	-- 						api_key_name = openrouter_secret,
	-- 					},
	-- 					or_gem_2_5_flash = {
	-- 						__inherited_from = "openai",
	-- 						endpoint = "https://openrouter.ai/api/v1",
	-- 						model = "google/gemini-2.5-flash",
	-- 						api_key_name = openrouter_secret,
	-- 					},
	-- 					or_gem_2_flash = {
	-- 						__inherited_from = "openai",
	-- 						endpoint = "https://openrouter.ai/api/v1",
	-- 						model = "google/gemini-2.0-flash-001",
	-- 						api_key_name = openrouter_secret,
	-- 					},
	-- 				},
	--
	-- 				provider = "or_v3",
	--
	-- 				--Setup suggestions <-- This is kinda bad...
	-- 				auto_suggestions_provider = "or_gem_2_flash",
	-- 				behavior = {
	-- 					auto_suggestions = false, -- <-- Enable later
	-- 				},
	-- 			}
	-- 			require("avante").setup(opts)
	-- 		end,
	-- 		keys = { { "<leader>a", group = "+ai" } },
	-- 	},
	-- 	{
	-- 		"mcphub.nvim",
	-- 		event = "VeryLazy",
	-- 		dependencies = { { "plenary.nvim" } },
	-- 		after = function()
	-- 			local opts = {
	-- 				extensions = {
	-- 					avante = {
	-- 						make_slash_commands = true,
	-- 					},
	-- 				},
	-- 			}
	-- 			require("mcphub").setup(opts)
	-- 		end,
	-- 	},
	{
		"claudecode.nvim",
		after = function(_, opts)
			require("claudecode").setup(opts)
		end,
		keys = {
			{ "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
			{ "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
			{ "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
			{ "<leader>ay", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
			{ "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
			{ "<leader>aR", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
			{ "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" }, -- [m]ail?
		},
	},
}

return M

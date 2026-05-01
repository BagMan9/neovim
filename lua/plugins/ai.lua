-- TODO: Re do all AI config, disabling for now
local M = {}
local openrouter_secret = "cmd:cat /run/agenix/ai-key"

M.lz_specs = {
	-- 	,
	{
		"claudecode.nvim",
		source = {
			type = "github",
			owner = "coder",
			repo = "claudecode.nvim",
		},
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

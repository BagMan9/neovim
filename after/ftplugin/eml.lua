-- Enable spellcheck with American English
vim.opt_local.spell = true
vim.opt_local.spelllang = "en_us"

-- Set text width to 72 characters for clean wrapping
vim.opt_local.textwidth = 72

-- Disable auto-indent for email formatting
vim.opt_local.autoindent = false

-- Use spaces instead of tabs, with a 2-space indentation
vim.opt_local.expandtab = true
vim.opt_local.shiftwidth = 2
vim.opt_local.softtabstop = 2

-- Enable basic syntax highlighting for email
vim.cmd("syntax on")

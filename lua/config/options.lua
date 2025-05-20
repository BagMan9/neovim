-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
vim.g.snacks_animate = false
vim.g.kitty_navigator_password = "navig8"
vim.g.lazyvim_picker = "snacks"
vim.diagnostic.config({ virtual_lines = true, virtual_text = false })

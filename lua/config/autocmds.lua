-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
--

local function shouldSync()
  return vim.fn.filereadable(vim.fn.getcwd() .. "/.nvim_sync") == 1
end

local function get_relative_cwd()
  local cwd = vim.fn.getcwd()
  local home = vim.env.HOME
  if cwd:sub(1, #home) == home then
    return cwd:sub(#home + 2)
  else
    return cwd
  end
end

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = { "*" },
  callback = function()
    if shouldSync() then
      vim.fn.jobstart({
        "rsync",
        "-az",
        "--relative",
        vim.fn.expand("%:."),
        "peitho:" .. get_relative_cwd(),
      }, { detach = true })
    end
  end,
})

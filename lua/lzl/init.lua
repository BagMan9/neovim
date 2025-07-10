local M = {}
---Load init lzl
---@param opts? LzlConfigOptions
function M.lzl_setup(opts)
    ---@diagnostic disable-next-line: undefined-field
    local start = vim.uv.hrtime()
    vim.loader.enable()

    local Config = require("lzl.config")
    local Loader = require("lzl.lzl_loader")

    table.insert(package.loaders, 3, Loader.loader)

    Config.setup(opts)
    Loader.setup()

    ---@diagnostic disable-next-line: undefined-field
    local delta = vim.uv.hrtime() - start

    Loader.startup()

    vim.api.nvim_exec_autocmds("User", { pattern = "LazyDone", modeline = false })
end

return M

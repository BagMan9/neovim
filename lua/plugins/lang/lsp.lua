return {
  {
    "neovim/nvim-lspconfig",
    ---@class PluginLspOpts
    opts = {
      setup = {
        clangd = function(_, opts)
          opts.capabilities.offsetEncoding = { "utf-16" }
        end,
      },

      diagnostics = {
        virtual_text = false,
        virtual_lines = true,
      },
      ---@type lspconfig.options
      --- TODO: Figure out how to make more universal
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--compile-commands-dir=.",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
            "--query-driver=/nix/store/**/g++",
          },
          mason = false,
        },
        nil_ls = {
          mason = false,
        },
      },
    },
  },
  {
    "williamboman/mason.nvim",
    enabled = false,
    opts = { ensure_installed = {} },
  },
  { "williamboman/mason-lspconfig.nvim", enabled = false },
}

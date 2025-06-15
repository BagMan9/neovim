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
      servers = {
        clangd = {
          cmd = {
            "nc",
            "localhost",
            "9999",
            -- "--header-insertion=iwyu",
            -- "--completion-style=detailed",
            -- "--function-arg-placeholders",
            -- "--fallback-style=llvm",
            -- "--query-driver=/nix/store/**/g++",
          },
          mason = false,
        },
        nil_ls = {
          mason = false,
        },
      },
    },
  },
}

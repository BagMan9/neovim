return {
  "folke/trouble.nvim",
  opts = {
    modes = {
      lsp_base = {
        params = {
          include_current = false,
        },
      },
      lsp = {
        params = {
          include_current = false,
        },
        -- win = {
        --   type = "split",
        --   relative = "win",
        --   position = "right",
        --   size = 0.3,
        -- },
      },
    },
  },
}

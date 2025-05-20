return {
  { "folke/persistence.nvim", enabled = false },

  {
    "rmagatti/auto-session",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      auto_session_enabled = true,
      auto_save_enabled = true,
      auto_restore_enabled = true,
    },
    lazy = false,
  },
}

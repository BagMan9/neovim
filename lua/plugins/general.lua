-- TODO: Potential: Octo

return {
  { import = "plugins.interaction" },
  { import = "plugins.lang" },
  { import = "plugins.ui" },
  {
    "jsongerber/thanks.nvim",
    config = true,
    opts = {
      unstar_on_uninstall = true,
      ignore_authors = {
        "BagMan9",
      },
    },
  },
  {
    "ThePrimeagen/refactoring.nvim",
    keys = {
      {
        "<leader>rr",
        mode = { "n", "x" },
        function()
          require("telescope").extensions.refactoring.refactors()
        end,
        desc = "Refactor Menu",
      },
    },
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {},
  },
}

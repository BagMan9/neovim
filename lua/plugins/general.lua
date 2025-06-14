-- TODO: Potential: Octo

return {
  { import = "plugins.interaction" },
  { import = "plugins.lang" },
  { import = "plugins.ui" },
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

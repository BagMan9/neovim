return {

  {
    "chrisgrieser/nvim-scissors",
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
      {
        "<leader>as",
        mode = { "n", "x" },
        function()
          require("scissors").addNewSnippet()
        end,
        desc = "Add Snippet",
      },
      {
        "<leader>aE",
        mode = { "n" },
        function()
          require("scissors").editSnippet()
        end,
        desc = "Edit Snippet",
      },
    },
  },
  require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets" } }),
}

return {{
		"LuaSnip",
		lazy = true,
    after = function()
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { "./snippets" } })
    end
	},
{
    "nvim-scissors",
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
}

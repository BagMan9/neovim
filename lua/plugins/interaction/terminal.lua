return {

  {
    "mikesmithgh/kitty-scrollback.nvim",
    enabled = true,
    lazy = true,
    cmd = {
      "KittyScrollbackGenerateKittens",
      "KittyScrollbackCheckHealth",
      "KittyScrollbackGenerateCommandLineEditing",
    },
    event = { "User KittyScrollbackLaunch" },
    config = function()
      require("kitty-scrollback").setup()
    end,
  },

  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    config = function()
      require("smart-splits").setup({
        at_edge = function(context)
          local dmap = {
            left = "west",
            down = "south",
            up = "north",
            right = "east",
          }
          local ydirection = dmap[context.direction]
          local command = "yabai -m window --focus " .. ydirection

          if ydirection == "west" or ydirection == "east" then
            command = command .. " || /Users/isaac/MainBoard/displayhelper.sh " .. ydirection
          end

          vim.fn.system(command)
        end,

        multiplexer_integration = "tmux",
      })
    end,
  },
}

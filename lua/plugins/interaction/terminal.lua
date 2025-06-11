return {

  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    config = function()
      require("smart-splits").setup({
        at_edge = function(context)
          local dmap = {
            left = "l",
            down = "d",
            up = "u",
            right = "r",
          }
          -- TODO: Make per operating system!!
          local ydirection = dmap[context.direction]
          local command = "hyprctl dispatch hy3:movefocus " .. ydirection ..", nowarp";

          -- if ydirection == "west" or ydirection == "east" then
          --   command = command .. " || /Users/isaac/MainBoard/displayhelper.sh " .. ydirection
          -- end

          vim.fn.system(command)
        end,

        multiplexer_integration = "tmux",
      })
    end,
  },
}

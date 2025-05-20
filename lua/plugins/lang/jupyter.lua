local default_notebook = [[
  {
    "cells": [
     {
      "cell_type": "markdown",
      "metadata": {},
      "source": [
        ""
      ]
     }
    ],
    "metadata": {
     "kernelspec": {
      "display_name": "Python 3",
      "language": "python",
      "name": "python3"
     },
     "language_info": {
      "codemirror_mode": {
        "name": "ipython"
      },
      "file_extension": ".py",
      "mimetype": "text/x-python",
      "name": "python",
      "nbconvert_exporter": "python",
      "pygments_lexer": "ipython3"
     }
    },
    "nbformat": 4,
    "nbformat_minor": 5
  }
]]

local function new_notebook(filename)
  local path = filename .. ".ipynb"
  local file = io.open(path, "w")
  if file then
    file:write(default_notebook)
    file:close()
    vim.cmd("edit " .. path)
  else
    print("Error: Could not open new notebook file for writing.")
  end
end

vim.api.nvim_create_user_command("NewNotebook", function(opts)
  new_notebook(opts.args)
end, {
  nargs = 1,
  complete = "file",
})

return {
  {
    "3rd/image.nvim",
    opts = {
      max_width = 100,
      max_height = 12,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
    },
  },
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    build = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    init = function()
      vim.g.molten_image_provider = "image.nvim"
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = true -- Maybe change
      vim.g.molten_virt_text_output = true -- Watch for issues
      vim.g.molten_virt_lines_off_by_1 = true
    end,
    keys = {
      { "<localleader>mi", "<cmd>MoltenInit<cr>", desc = "Init Molten", silent = true },
      { "<localleader>oi", "<cmd>MoltenImagePopup<cr>", desc = "Popup image", silent = true },
      { "<localleader>md", "<cmd>MoltenDelete<cr>", desc = "Delete Molten Cell", silent = true },
      { "<localleader>e", "<cmd>MoltenEvaluateOperator<cr>", desc = "Run Operator Selection", silent = true },
      { "<localleader>rr", "<cmd>MoltenReevaluateCell<cr>", desc = "Reeval Cell", silent = true },
      -- { "<localleader>r", "<C-u>MoltenEvaluateVisual<cr>", mode = { "v" }, desc = "Reeval Selection", silent = true },
      { "<localleader>os", "<cmd>noautocmd MoltenEnterOutput<cr>", desc = "Open output window", silent = true },
      { "<localleader>oh", "<cmd>MoltenHideOutput<cr>", desc = "Close Output Window", silent = true },
      { "<localleader>cc", "<cmd>MoltenInterrupt<cr>", desc = "Sends Interrupt (control-c)", silent = true },
    },
  },
  {
    "GCBallesteros/jupytext.nvim",
    opts = {
      style = "markdown",
      output_extension = "md",
      force_ft = "markdown",
    },
  },
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      lspFeatures = {
        enabled = true,
        languages = { "python" },
        chunks = "all",
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
        completion = {
          enabled = true,
        },
      },
      codeRunner = {
        enabled = true,
        default_method = "molten",
      },
    },
    ft = { "quarto", "markdown" },
  },
}

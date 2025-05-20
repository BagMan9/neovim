local fn = vim.fn

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function()
    local utils = require("config.utils")
    local copilot_colors = {
      [""] = utils.get_hlgroup("Comment"),
      ["Normal"] = utils.get_hlgroup("Comment"),
      ["Warning"] = utils.get_hlgroup("DiagnosticError"),
      ["InProgress"] = utils.get_hlgroup("DiagnosticWarn"),
    }
    local function diff_source()
      local gitsigns = vim.b.gitsigns_status_dict
      if gitsigns then
        return {
          added = gitsigns.added,
          modified = gitsigns.changed,
          removed = gitsigns.removed,
        }
      end
    end
    -- Gets Lines & Chars selected
    local function selectionCount()
      local isVisualMode = fn.mode():find("[Vv]")
      if not isVisualMode then
        return ""
      end
      local starts = fn.line("v")
      local ends = fn.line(".")
      local lines = starts <= ends and ends - starts + 1 or starts - ends + 1
      return " " .. tostring(lines) .. "L " .. tostring(fn.wordcount().visual_chars) .. "C"
    end
    local colors = require("catppuccin.palettes").get_palette("mocha")

    local function moltenInfo()
      local status = require("molten.status").initialized()
      if status ~= "" then
        local kernels = require("molten.status").kernels()
        return kernels
      else
        return ""
      end
    end

    return {
      options = {
        component_separators = { left = " ", right = " " },
        section_separators = { left = " ", right = " " },
        theme = "catppuccin",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha" } },
      },
      sections = {
        lualine_a = {
          {
            "mode",
            icon = "",
            color = function()
              local modes = {
                n = colors.blue,
                i = colors.green,
                v = colors.lavender,
                ["␖"] = colors.blue,
                V = colors.blue,
                c = colors.pink,
                no = colors.red,
                s = colors.peach,
                S = colors.peach,
                ["␓"] = colors.peach,
                ic = colors.yellow,
                R = colors.lavender,
                Rv = colors.lavender,
                cv = colors.red,
                ce = colors.red,
                r = colors.teal,
                rm = colors.teal,
                ["r?"] = colors.teal,
                ["!"] = colors.red,
                t = colors.red,
              }
              return { fg = modes[vim.fn.mode()], bg = "#1E1E2E" }
            end,
          },
        },
        lualine_b = {
          { "b:gitsigns_head", icon = "", color = { bg = "#1E1E2E" } },
        },
        lualine_c = {
          {
            "diagnostics",
            symbols = {
              error = " ",
              warn = " ",
              info = " ",
              hint = "󰝶 ",
            },
          },
          { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
          { "filename", padding = { left = 1, right = 0 } },

          {
            function()
              return require("nvim-navic").get_location()
            end,
            cond = function()
              return package.loaded["nvim-navic"] and require("nvim-navic").is_available()
            end,
            color = { fg = colors.text, bg = "#1E1E2E" },
          },
        },
        lualine_x = {
          {
            "diff",
            source = diff_source(),
            symbols = { added = "󰐖 ", modified = "󰿠 ", removed = " " },
            color = { bg = "#1E1E2E" },
          },
          {
            moltenInfo,
            color = { fg = colors.yellow },
          },
        },
        lualine_y = {
          { selectionCount, color = { bg = "#1E1E2E" } },
        },
        lualine_z = {
          {
            "progress",
            color = { fg = colors.blue, bg = "#1E1E2E" },
          },
          {
            "location",
            color = utils.get_hlgroup("Boolean"),
          },
        },
      },

      extensions = { "lazy", "toggleterm", "mason", "neo-tree", "trouble" },
    }
  end,
}

return {
  {
    "catppuccin/nvim",
    lazy = false,
    opts = {
      transparent_background = true,
      dim_inactive = {
        enabled = true,
        shade = "dark",
        percentage = 0.20,
      },
      styles = {
        booleans = { "italic" },
        keywords = { "italic" },
        types = { "italic" },
        loops = { "italic" },
      },

      custom_highlights = function(_)
        return {
          DiagnosticError = { style = { "bold", "italic" } },
          DiagnosticVirtualTextError = { style = { "bold", "italic" } },
          DiagnosticWarn = { style = { "bold", "italic" } },
          DiagnosticVirtualTextWarn = { style = { "bold", "italic" } },
          DiagnosticInfo = { style = { "bold", "italic" } },
          DiagnosticVirtualTextInfo = { style = { "bold", "italic" } },
          DiagnosticHint = { style = { "bold", "italic" } },
          DiagnosticVirtualTextHint = { style = { "bold", "italic" } },
        }
      end,
    },
  },

  { "LazyVim/LazyVim", opts = {
    colorscheme = "catppuccin",
  } },
}

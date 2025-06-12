return {
{
	"lualine.nvim",
		after = function()
		local utils = Utils
    local fn = vim.fn
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

    local opts = {
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
          {
            "filetype",
            icon_only = true,
            separator = "",
            padding = { left = 1, right = 0 },
            color = { bg = "#1e1e2e" },
          },
          { "filename", padding = { left = 0, right = 0 }, color = { bg = "#1e1e2e" } },
          {
            "diff",
            source = diff_source(),
            symbols = { added = "󰐖 ", modified = "󰿠 ", removed = " " },
            color = { bg = "#1E1E2E" },
          },
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
          -- {
          --   moltenInfo,
          --   color = { fg = colors.yellow },
          -- },
        },
        lualine_y = {
          { selectionCount, color = { bg = "#1E1E2E" } },
        },
        lualine_z = {
          {
            "progress",
            color = { fg = colors.blue, bg = "#1E1E2E" },
          },
          { --FIXME: Why broken??
            "location",
            color = utils.get_hlgroup("Boolean"),
          },
        },
      },

      extensions = { "lazy", "toggleterm", "mason", "neo-tree", "trouble" },
    }
    require("lualine").setup(opts)
		end,
		event = "DeferredUIEnter",
	},

{
		"bufferline.nvim",
		event = "DeferredUIEnter",
		keys = {
			{ "<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle Pin" },
			{ "<leader>bP", "<Cmd>BufferLineGroupClose ungrouped<CR>", desc = "Delete Non-Pinned Buffers" },
			{ "<leader>br", "<Cmd>BufferLineCloseRight<CR>", desc = "Delete Buffers to the Right" },
			{ "<leader>bl", "<Cmd>BufferLineCloseLeft<CR>", desc = "Delete Buffers to the Left" },
			{ "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
			{ "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
			{ "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
			{ "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
			{ "[B", "<cmd>BufferLineMovePrev<cr>", desc = "Move buffer prev" },
			{ "]B", "<cmd>BufferLineMoveNext<cr>", desc = "Move buffer next" },
		},
    before = function()
      require("lz.n").trigger_load("mini.icons")

    end,
		after = function()
			local opts = {
				options = {
        -- stylua: ignore
        close_command = function(n) require("snacks").bufdelete(n) end,
        -- stylua: ignore
        right_mouse_command = function(n) require("snacks").bufdelete(n) end,
					diagnostics = "nvim_lsp",
					always_show_bufferline = false,
					diagnostics_indicator = function(_, _, diag)
						local icons = Utils.lazy_defaults.icons.diagnostics
						local ret = (diag.error and icons.Error .. diag.error .. " " or "")
							.. (diag.warning and icons.Warn .. diag.warning or "")
						return vim.trim(ret)
					end,
					offsets = {
						{
							filetype = "neo-tree",
							text = "Neo-tree",
							highlight = "Directory",
							text_align = "left",
						},
						{
							filetype = "snacks_layout_box",
						},
					},
          color_icones = true,
          show_buffer_icons = true,
					---@param opts bufferline.IconFetcherOpts
					get_element_icon = function(opts)
						return Utils.lazy_defaults.icons.ft[opts.filetype]
					end,
				},
        highlights = require("catppuccin.groups.integrations.bufferline").get()
			}
      
			--PREVIOUS CONFIG
			require("bufferline").setup(opts)
			-- Fix bufferline when restoring a session
			vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
				callback = function()
					vim.schedule(function()
						pcall(nvim_bufferline)
					end)
				end,
			})
		end,
	},
	{
		"noice.nvim",
		enabled = true,
		after = function()
			local opts = {
				lsp = {
					override = {
						["vim.lsp.util.convert_input_to_markdown_lines"] = true,
						["vim.lsp.util.stylize_markdown"] = true,
						["cmp.entry.get_documentation"] = true,
					},
				},
				routes = {
					{
						filter = {
							event = "msg_show",
							any = {
								{ find = "%d+L, %d+B" },
								{ find = "; after #%d+" },
								{ find = "; before #%d+" },
							},
						},
						view = "mini",
					},
				},
				presets = {
          inc_rename = true,
					bottom_search = true,
					command_palette = true,
					long_message_to_split = true,
				},
			}
			-- HACK: noice shows messages from before it was enabled,
			-- but this is not ideal when Lazy is installing plugins,
			-- so clear the messages in this case.
			if vim.o.filetype == "lazy" then
				vim.cmd([[messages clear]])
			end
			require("noice").setup(opts)
		end,
		event = "DeferredUIEnter",
		keys = {
			{ "<leader>sn", "", desc = "+noice" },
			{
				"<S-Enter>",
				function()
					require("noice").redirect(vim.fn.getcmdline())
				end,
				mode = "c",
				desc = "Redirect Cmdline",
			},
			{
				"<leader>snl",
				function()
					require("noice").cmd("last")
				end,
				desc = "Noice Last Message",
			},
			{
				"<leader>snh",
				function()
					require("noice").cmd("history")
				end,
				desc = "Noice History",
			},
			{
				"<leader>sna",
				function()
					require("noice").cmd("all")
				end,
				desc = "Noice All",
			},
			{
				"<leader>snd",
				function()
					require("noice").cmd("dismiss")
				end,
				desc = "Dismiss All",
			},
			{
				"<leader>snt",
				function()
					require("noice").cmd("pick")
				end,
				desc = "Noice Picker (Telescope/FzfLua)",
			},
			{
				"<c-f>",
				function()
					if not require("noice.lsp").scroll(4) then
						return "<c-f>"
					end
				end,
				silent = true,
				expr = true,
				desc = "Scroll Forward",
				mode = { "i", "n", "s" },
			},
			{
				"<c-b>",
				function()
					if not require("noice.lsp").scroll(-4) then
						return "<c-b>"
					end
				end,
				silent = true,
				expr = true,
				desc = "Scroll Backward",
				mode = { "i", "n", "s" },
			},
		},
	},
{
		"mini.icons",
		lazy = true,
    beforeAll = function ()
package.preload["nvim-web-devicons"] = function()
  require("mini.icons").mock_nvim_web_devicons()
  return package.loaded["nvim-web-devicons"]
end
    end,
		after = function()
			local opts = {
				file = {
					[".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
					["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
				},
				filetype = {
					dotenv = { glyph = "", hl = "MiniIconsYellow" },
				},
			}
		end,
	},
}

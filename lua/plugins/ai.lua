return {
  {
    "yetone/avante.nvim",
    -- This is really bad, need to fix and get this better
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below is optional, make sure to setup it properly if you have lazy=true
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
    opts = function()
      vim.opt.laststatus = 3
      vim.opt.splitkeep = "screen"
      ---@class avante.Config
      return {
        provider = "deepseekthree",
        copilot = {
          endpoint = "https://api.githubcopilot.com",
          model = "claude-3.5-sonnet",
          proxy = nil,
          allow_insecure = false,
          timeout = 30000,
          temperature = 0,
          max_tokens = 4096,
        },
        vendors = {
          ["qwen"] = {
            endpoint = "https://api.together.xyz/v1/chat/completions",
            model = "Qwen/Qwen2.5-Coder-32B-Instruct",
            api_key_name = "TOGETHER_API_KEY",
            ---@type fun(opts: AvanteProvider, code_opts: AvantePromptOptions): AvanteCurlOutput
            parse_curl_args = function(opts, code_opts)
              return {
                url = opts.endpoint,
                headers = {
                  ["Authorization"] = "Bearer " .. os.getenv(opts.api_key_name),
                  ["Content-Type"] = "application/json",
                },
                body = {
                  model = opts.model,
                  messages = { -- you can make your own message, but this is very advanced
                    { role = "system", content = code_opts.system_prompt },
                    { role = "user", content = require("avante.providers.openai").get_user_message(code_opts) },
                  },
                  temperature = 0.6,
                  -- max_tokens = 4096,
                  stream = true, -- this will be set by default.
                },
              }
            end,
            parse_response_data = function(data_stream, event_state, opts)
              require("avante.providers").openai.parse_response(data_stream, event_state, opts)
            end,
          },
          ["deepseekthree"] = {
            __inherited_from = "openai",
            api_key_name = "OPENROUTER_API_KEY",
            endpoint = "https://openrouter.ai/api/v1/",
            model = "deepseek/deepseek-chat",
          },
        },
        behaviour = {
          auto_suggestions = false,
        },
        windows = {
          width = 35,
          sidebar_header = {
            enabled = false,
          },
          ask = {
            floating = false,
          },
        },
      }
    end,
  },
}

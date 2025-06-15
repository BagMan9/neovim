local function get_relative_cwd()
  local cwd = vim.fn.getcwd()
  local home = vim.env.HOME
  if cwd:sub(1, #home) == home then
    return cwd:sub(#home + 2)
  else
    return cwd
  end
end

return {

  {
    "jay-babu/mason-nvim-dap.nvim",
    enable = false,
    opts = { automatic_installation = false },
  },
  {

    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")
      dap.adapters.remotecpp = {
        type = "executable",
        command = "/Users/isaac/Dev/codelldb/extension/adapter/codelldb",
      }
      for _, lang in ipairs({ "cpp", "cuda" }) do
        dap.configurations[lang] = {
          {
            type = "remotecpp",
            request = "launch",
            name = "Remote Debug",
            initCommands = {
              "platform select remote-linux",
              "platform connect connect://100.115.79.12:9998",
              -- "process handle -n false -p true -s false SIGSTOP",
              "settings set target.import-std-module true",
              "settings set target.inherit-env false",
            },
            targetCreateCommands = { "target create app" },
            stopOnEntry = false,
            stopOnExit = true,
            -- processCreateCommands = { "run" },
            -- sourceMap = { ["/Users/isaac/" .. get_relative_cwd()] = "/home/isaac/" .. get_relative_cwd() },
            -- cwd = "/home/isaac/" .. get_relative_cwd(),
          },
          {
            type = "remotecpp",
            request = "attach",
            name = "Attach to process",
            pid = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
        }
      end
    end,
  },
}

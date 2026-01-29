local ios_fts = { "swift", "objc", "objcpp", "metal" }
local M = {}

M.lz_specs = {
	{
		"nvim-dap",
		source = {
			type = "github",
			repo = "nvim-dap",
			owner = "mfussenegger",
		},
		dependencies = {
			{
				"nvim-dap-python",
				source = {
					type = "github",
					repo = "nvim-dap-python",
					owner = "mfussenegger",
					branch = "master",
				},
				build = {
					nixDeps = { "nvim-dap" },
				},
				after = function(_, opts)
					require("dap-python").setup("debugpy-adapter")
				end,
			},
			{
				"nvim-dap-virtual-text",
				source = {
					type = "github",
					repo = "nvim-dap-virtual-text",
					owner = "theHamsta",
					branch = "master",
				},
				build = {
					nixDeps = { "nvim-dap" },
				},
				lazy = true,
				after = function()
					require("nvim-dap-virtual-text").setup()
				end,
			},
		},
		keys = {
			{
				"<leader>dB",
				function()
					require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "Breakpoint Condition",
			},
			{
				"<leader>db",
				function()
					require("dap").toggle_breakpoint()
				end,
				desc = "Toggle Breakpoint",
			},
			{
				"<leader>dc",
				function()
					require("dap").continue()
				end,
				desc = "Continue",
			},
			{
				"<leader>da",
				function()
					require("dap").continue({ before = get_args })
				end,
				desc = "Run with Args",
			},
			{
				"<leader>dC",
				function()
					require("dap").run_to_cursor()
				end,
				desc = "Run to Cursor",
			},
			{
				"<leader>dR",
				function()
					require("dap").run_last()
				end,
				desc = "Run Last",
			},
			{
				"<leader>dg",
				function()
					require("dap").goto_()
				end,
				desc = "Go to Line (No Execute)",
			},
			{
				"<leader>di",
				function()
					require("dap").step_into()
				end,
				desc = "Step Into",
			},
			{
				"<leader>dj",
				function()
					require("dap").down()
				end,
				desc = "Down",
			},
			{
				"<leader>dk",
				function()
					require("dap").up()
				end,
				desc = "Up",
			},
			{
				"<leader>dl",
				function()
					require("dap").run_last()
				end,
				desc = "Run Last",
			},
			{
				"<leader>do",
				function()
					require("dap").step_out()
				end,
				desc = "Step Out",
			},
			{
				"<leader>dO",
				function()
					require("dap").step_over()
				end,
				desc = "Step Over",
			},
			{
				"<leader>dP",
				function()
					require("dap").pause()
				end,
				desc = "Pause",
			},
			{
				"<leader>dr",
				function()
					require("dap").repl.toggle()
				end,
				desc = "Toggle REPL",
			},
			{
				"<leader>ds",
				function()
					require("dap").session()
				end,
				desc = "Session",
			},
			{
				"<leader>dt",
				function()
					require("dap").terminate()
				end,
				desc = "Terminate",
			},
			{
				"<leader>dw",
				function()
					require("dap.ui.widgets").hover()
				end,
				desc = "Widgets",
			},
		},
		after = function()
			vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })

			for name, sign in pairs(Utils.lazy_defaults.icons.dap) do
				sign = type(sign) == "table" and sign or { sign }
				vim.fn.sign_define(
					"Dap" .. name,
					{ text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
				)
			end

			-- setup dap config by VsCode launch.json file
			local vscode = require("dap.ext.vscode")
			local json = require("plenary.json")
			vscode.json_decode = function(str)
				return vim.json.decode(json.json_strip_comments(str))
			end
			local dap = require("dap")
			dap.adapters.remotecpp = {
				type = "executable",
				command = "/Users/isaac/Dev/codelldbpath/extension/adapter/codelldb",
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
	{
		"nvim-dap-ui",
		source = {
			type = "github",
			repo = "nvim-dap-ui",
			owner = "rcarriga",
		},
		build = { useNixpkgs = "nvim-dap-ui" },
		dependencies = { { "nvim-nio" }, { "nvim-dap" } },
		keys = {
			{
				"<leader>du",
				function()
					require("dapui").toggle({})
				end,
				desc = "Dap UI",
			},
			{
				"<leader>de",
				function()
					require("dapui").eval()
				end,
				desc = "Eval",
				mode = { "n", "v" },
			},
		},
		opts = {
			floating = {
				mappings = {
					close = { "q", "<Esc>" },
				},
			},
		},
		after = function(_, opts)
			local dap = require("dap")
			local dapui = require("dapui")
			dapui.setup(opts)
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open({})
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close({})
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close({})
			end

			dapui.setup()
		end,
	},
	{
		"which-key.nvim",
		opts = {
			specs = {
				{ "<leader>d", group = "debug" },
				{ "<leader>dp", group = "profiler" },
			},
		},
	},
}

return M

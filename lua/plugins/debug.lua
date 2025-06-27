local ios_fts = { "swift", "objc", "objcpp", "metal" }
return {
	{
		"nvim-dap",
		before = function()
			-- require("lz.n").trigger_load("nvim-dap-virtual-text")
		end,
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
			-- TODO: Figure out how much of this can go in normal debug binds
			{
				"<localleader>dd",
				function()
					require("xcodebuild.integrations.dap").build_and_debug()
				end,
				mode = { "n" },
				desc = "Build & Debug",
				-- ft = ios_fts,
			},
			{
				"<localleader>dr",
				function()
					require("xcodebuild.integrations.dap").debug_without_build()
				end,
				mode = { "n" },
				desc = "Debug Without Building",
				-- ft = ios_fts,
			},
			{
				"<localleader>dt",
				function()
					require("xcodebuild.integrations.dap").debug_tests()
				end,
				mode = { "n" },
				desc = "Debug Tests",
				-- ft = ios_fts,
			},
			{
				"<localleader>dT",
				function()
					require("xcodebuild.integrations.dap").debug_class_tests()
				end,
				mode = { "n" },
				desc = "Debug Class Tests",
				-- ft = ios_fts,
			},
			{
				"<localleader>b",
				function()
					require("xcodebuild.integrations.dap").toggle_breakpoint()
				end,
				mode = { "n" },
				desc = "Toggle Breakpoint",
				-- ft = ios_fts,
			},
			{
				"<localleader>B",
				function()
					require("xcodebuild.integrations.dap").toggle_message_breakpoint()
				end,
				mode = { "n" },
				desc = "Toggle Message Breakpoint",
				-- ft = ios_fts,
			},
			{
				"<localleader>dx",
				function()
					require("xcodebuild.integrations.dap").terminate_session()
				end,
				mode = { "n" },
				desc = "Terminate Debugger",
				-- ft = ios_fts,
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
			require("lz.n").trigger_load({ "nvim-dap-ui", "nvim-dap-virtual-text", "nvim-dap-python" })
		end,
	},
	{
		"nvim-dap-ui",
		dependencies = { "nvim-nio" },
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
		after = function()
			local opts = {
				floating = {
					mappings = {
						close = { "q", "<Esc>" },
					},
				},
			}
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
		lazy = true,
		"nvim-dap-virtual-text",
		after = function()
			require("nvim-dap-virtual-text").setup()
		end,
	},
	{
		lazy = true,
		"nvim-dap-python",
		after = function()
			require("dap-python").setup("debugpy-adapter")
		end,
	},
}

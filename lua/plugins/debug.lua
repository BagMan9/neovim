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
		build = {
			useNixpkgs = "nvim-dap",
		},
		dependencies = {
			{
				"nvim-dap-ui",
			},
			{
				"nvim-dap-python",
				source = {
					type = "github",
					repo = "nvim-dap-python",
					owner = "mfussenegger",
					branch = "master",
				},
				build = {
					useNixpkgs = "nvim-dap-python",
					-- nixDeps = { "nvim-dap" },
				},
				extraPackages = {
					"python3Packages.debugpy",
				},
				after = function(_, opts)
					require("dap-python").setup("debugpy-adapter")

					fallback = require("dap-python").resolve_python
					require("dap-python").resolve_python = function()
						---@type string
						local pathenv = vim.fn.environ()["PATH"]
						local nixenv = pathenv:match("/nix/store/[%l%d]+%-python3?%-[%d.]+%-env/bin")
						if nixenv then
							return nixenv .. "/python3"
						else
							return fallback()
						end
					end
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
				opts = {
					virt_text_pos = "eol",
				},
				lazy = true,
				after = function(_, opts)
					require("nvim-dap-virtual-text").setup(opts)
				end,
			},
		},
		keys = {
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

			-- Session-scoped Alt-chord controls: bound globally only while a
			-- debug session is live (any language), removed when it ends. Global
			-- + modeless so they work in the source buffer and every dap-ui pane,
			-- and they don't occupy the keys outside of debugging.
			local session_keys = {
				{
					"<A-k>",
					function()
						require("dap.ui.widgets").hover()
					end,
					desc = "Widgets",
				},
				{
					"<A-c>",
					function()
						require("dap").continue()
					end,
					"Continue",
				},
				{
					"<A-C>",
					function()
						require("dap").run_to_cursor()
					end,
					desc = "Run to Cursor",
				},
				{
					"<A-i>",
					function()
						require("dap").step_into()
					end,
					"Step Into",
				},
				{
					"<A-o>",
					function()
						require("dap").step_over()
					end,
					"Step Over",
				},
				{
					"<A-O>",
					function()
						require("dap").step_out()
					end,
					"Step Out",
				},
				{
					"<A-b>",
					function()
						require("dap").toggle_breakpoint()
					end,
					"Toggle Breakpoint",
				},
				{
					"<A-t>",
					function()
						require("dap").terminate()
					end,
					"Terminate",
				},
			}
			local function set_session_keys()
				for _, k in ipairs(session_keys) do
					vim.keymap.set("n", k[1], k[2], { desc = "Debug: " .. (k[3] and k[3] or "") })
				end
			end
			local function clear_session_keys()
				for _, k in ipairs(session_keys) do
					pcall(vim.keymap.del, "n", k[1])
				end
			end
			dap.listeners.after.event_initialized["session_keys"] = set_session_keys
			dap.listeners.after.event_terminated["session_keys"] = clear_session_keys
			dap.listeners.after.event_exited["session_keys"] = clear_session_keys

			dap.adapters.remotecpp = {
				type = "executable",
				command = "codelldb",
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
			branch = "master",
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
			spec = {
				{ "<leader>d", group = "debug" },
				{ "<leader>dp", group = "profiler" },
			},
		},
	},
}

return M

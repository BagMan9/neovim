local ios_fts = { "swift", "objc", "objcpp", "metal" }
-- Code coverage
-- NOTE: Inject + simulator preview seems ~fine for now, keep in background
--
-- Need swift dependencies to properly see device targets: https://github.com/wojciech-kulik/require("xcodebuild.integrations.dap").nvim/issues/285
-- Await sourcekit update, inlay hints currently disabled https://github.com/swiftlang/sourcekit-lsp/issues/2021
return {
	-- {
	-- 	"nvim-lspconfig",
	-- 	opts = {
	-- 		servers = {
	-- 			-- TODO: Get swift debugger?? lldb-dap
	-- 			sourcekit = {
	-- 				enabled = true,
	-- 				capabilities = {
	-- 					workspace = {
	-- 						didChangeWatchedFiles = {
	-- 							dynamicRegistration = true,
	-- 						},
	-- 					},
	-- 				},
	-- 			},
	-- 		},
	-- 		setup = {
	-- 			sourcekit = function()
	-- 				Utils.lsp.on_attach(function(client, _)
	-- 					client.server_capabilities.inlayHintProvider = false
	-- 				end)
	-- 			end,
	-- 		},
	-- 	},
	-- },
	{
		"conform.nvim",
		opts = {
			formatters_by_ft = {
				swift = { "swiftformat" },
			},
		},
	},
	{
		"nvim-lint",
		opts = {
			linters_by_ft = {
				swift = { "swiftlint" },
			},
		},
	},
	{
		"xcodebuild.nvim",
		---@diagnostic disable-next-line: undefined-field
		cond = vim.loop.os_uname().sysname == "Darwin",
		ft = ios_fts,
		dependencies = {
			{
				"telescope.nvim",
				lazy = true,
				event = "VeryLazy",
				dependencies = { { "plenary.nvim" } },
				after = function(_, opts)
					require("telescope").setup(opts)
				end,
			},
			{
				"fidget.nvim",
				opts = {
					integration = {
						["xcodebuild-nvim"] = {
							enable = true,
						},
					},
				},
			},
			{ "neo-tree.nvim" },
			{ "nvim-dap" },
		},
		after = function()
			local progress_handle
			local opts = {
				logs = {
					notify = function(message, severity)
						local fidget = require("fidget")
						if progress_handle then
							progress_handle.message = message
							if not message:find("Loading") then
								progress_handle:finish()
								progress_handle = nil
								if vim.trim(message) ~= "" then
									fidget.notify(message, severity)
								end
							end
						else
							fidget.notify(message, severity)
						end
					end,
					notify_progress = function(message)
						local progress = require("fidget.progress")

						if progress_handle then
							progress_handle.title = ""
							progress_handle.message = message
						else
							progress_handle = progress.handle.create({
								message = message,
								lsp_client = { name = "xcodebuild.nvim" },
							})
						end
					end,
				},
				integrations = {
					xcode_build_server = {
						enabled = true,
					},
				},
			}
			require("xcodebuild").setup(opts)

			local codelldb_path = os.getenv("HOME") .. "/Dev/codelldbpath/extension/adapter/codelldb"
			require("xcodebuild.integrations.dap").setup(codelldb_path)
		end,
		keys = {
			{
				"<localleader>X",
				"<cmd>XcodebuildPicker<cr>",
				mode = { "n" },
				desc = "Show Xcodebuild Actions",
				ft = ios_fts,
			},
			{
				"<localleader>xf",
				"<cmd>XcodebuildProjectManager<cr>",
				mode = { "n" },
				desc = "Show Project Manager Actions",
				ft = ios_fts,
			},

			{
				"<localleader>xb",
				"<cmd>XcodebuildBuild<cr>",
				mode = { "n" },
				desc = "Build Project",
				ft = ios_fts,
			},
			{
				"<localleader>xB",
				"<cmd>XcodebuildBuildForTesting<cr>",
				mode = { "n" },
				desc = "Build For Testing",
				ft = ios_fts,
			},
			{
				"<localleader>xr",
				"<cmd>XcodebuildBuildRun<cr>",
				mode = { "n" },
				desc = "Build & Run Project",
				ft = ios_fts,
			},

			{
				"<localleader>xt",
				"<cmd>XcodebuildTest<cr>",
				mode = { "n" },
				desc = "Run Tests",
				ft = ios_fts,
			},
			{
				"<localleader>xt",
				"<cmd>XcodebuildTestSelected<cr>",
				mode = { "v" },
				desc = "Run Selected Tests",
				ft = ios_fts,
			},
			{
				"<localleader>xT",
				"<cmd>XcodebuildTestClass<cr>",
				mode = { "n" },
				desc = "Run Current Test Class",
				ft = ios_fts,
			},
			{
				"<localleader>x.",
				"<cmd>XcodebuildTestRepeat<cr>",
				mode = { "n" },
				desc = "Repeat Last Test Run",
				ft = ios_fts,
			},

			{
				"<localleader>xl",
				"<cmd>XcodebuildToggleLogs<cr>",
				mode = { "n" },
				desc = "Toggle Xcodebuild Logs",
				ft = ios_fts,
			},
			{
				"<localleader>xc",
				"<cmd>XcodebuildToggleCodeCoverage<cr>",
				mode = { "n" },
				desc = "Toggle Code Coverage",
				ft = ios_fts,
			},
			{
				"<localleader>xC",
				"<cmd>XcodebuildShowCodeCoverageReport<cr>",
				mode = { "n" },
				desc = "Show Code Coverage Report",
				ft = ios_fts,
			},
			{
				"<localleader>xe",
				"<cmd>XcodebuildTestExplorerToggle<cr>",
				mode = { "n" },
				desc = "Toggle Test Explorer",
				ft = ios_fts,
			},
			{
				"<localleader>xs",
				"<cmd>XcodebuildFailingSnapshots<cr>",
				mode = { "n" },
				desc = "Show Failing Snapshots",
				ft = ios_fts,
			},

			{
				"<localleader>xp",
				"<cmd>XcodebuildPreviewGenerateAndShow hotReload<cr>",
				mode = { "n" },
				desc = "Generate Preview",
				ft = ios_fts,
			},
			{
				"<localleader>x<cr>",
				"<cmd>XcodebuildPreviewToggle<cr>",
				mode = { "n" },
				desc = "Toggle Preview",
				ft = ios_fts,
			},

			{
				"<localleader>xd",
				"<cmd>XcodebuildSelectDevice<cr>",
				mode = { "n" },
				desc = "Select Device",
				ft = ios_fts,
			},
			{
				"<localleader>xq",
				"<cmd>Telescope quickfix<cr>",
				mode = { "n" },
				desc = "Show QuickFix List",
				ft = ios_fts,
			},

			{
				"<localleader>xx",
				"<cmd>XcodebuildQuickfixLine<cr>",
				mode = { "n" },
				desc = "Quickfix Line",
				ft = ios_fts,
			},
			{
				"<localleader>xa",
				"<cmd>XcodebuildCodeActions<cr>",
				mode = { "n" },
				desc = "Show Code Actions",
				ft = ios_fts,
			},
			-- TODO: Figure out how much of this can go in normal debug binds
			{
				"<localleader>dd",
				function()
					require("xcodebuild.integrations.dap").build_and_debug()
				end,
				mode = { "n" },
				desc = "Build & Debug",
				ft = ios_fts,
			},
			{
				"<localleader>dr",
				function()
					require("xcodebuild.integrations.dap").debug_without_build()
				end,
				mode = { "n" },
				desc = "Debug Without Building",
				ft = ios_fts,
			},
			{
				"<localleader>dt",
				function()
					require("xcodebuild.integrations.dap").debug_tests()
				end,
				mode = { "n" },
				desc = "Debug Tests",
				ft = ios_fts,
			},
			{
				"<localleader>dT",
				function()
					require("xcodebuild.integrations.dap").debug_class_tests()
				end,
				mode = { "n" },
				desc = "Debug Class Tests",
				ft = ios_fts,
			},
			{
				"<localleader>b",
				function()
					require("xcodebuild.integrations.dap").toggle_breakpoint()
				end,
				mode = { "n" },
				desc = "Toggle Breakpoint",
				ft = ios_fts,
			},
			{
				"<localleader>B",
				function()
					require("xcodebuild.integrations.dap").toggle_message_breakpoint()
				end,
				mode = { "n" },
				desc = "Toggle Message Breakpoint",
				ft = ios_fts,
			},
			{
				"<localleader>dx",
				function()
					require("xcodebuild.integrations.dap").terminate_session()
				end,
				mode = { "n" },
				desc = "Terminate Debugger",
				ft = ios_fts,
			},
		},
	},
	{
		"which-key.nvim",
		opts = { spec = { { "<localleader>x", group = "xcode" }, { "<localleader>d", group = "xcode debug" } } },
	},
	{
		"snacks.nvim",
		opts = {
			image = { enabled = true, focusable = false },
		},
	},
}

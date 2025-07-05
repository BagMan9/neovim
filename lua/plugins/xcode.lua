local ios_fts = { "swift", "objc", "objcpp", "metal" }
return {
	-- TODO:
	-- In order:
	-- Also get sourcekit generally configured
	-- Get plugin configured
	--
	-- Code coverage
	-- NOTE: Inject + simulator preview seems ~fine for now, keep in background
	--
	-- Need swift dependencies to properly see device targets: https://github.com/wojciech-kulik/require("xcodebuild.integrations.dap").nvim/issues/285
	-- Await sourcekit update, inlay hints currently disabled https://github.com/swiftlang/sourcekit-lsp/issues/2021
	{
		"xcodebuild.nvim",
		enabled = true,
		ft = ios_fts,
		before = function()
			require("lz.n").trigger_load({ "telescope.nvim", "fidget.nvim" })
		end,
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
			require("lz.n").trigger_load("nvim-dap")

			local codelldb_path = os.getenv("HOME") .. "/Dev/codelldbpath/extension/adapter/codelldb"
			require("xcodebuild.integrations.dap").setup(codelldb_path)
		end,
		keys = {
			{
				"<localleader>X",
				"<cmd>XcodebuildPicker<cr>",
				mode = { "n" },
				desc = "Show Xcodebuild Actions",
				-- ft = ios_fts,
			},
			{
				"<localleader>xf",
				"<cmd>XcodebuildProjectManager<cr>",
				mode = { "n" },
				desc = "Show Project Manager Actions",
				-- ft = ios_fts,
			},

			{
				"<localleader>xb",
				"<cmd>XcodebuildBuild<cr>",
				mode = { "n" },
				desc = "Build Project",
				-- ft = ios_fts
			},
			{
				"<localleader>xB",
				"<cmd>XcodebuildBuildForTesting<cr>",
				mode = { "n" },
				desc = "Build For Testing",
				-- ft = ios_fts,
			},
			{
				"<localleader>xr",
				"<cmd>XcodebuildBuildRun<cr>",
				mode = { "n" },
				desc = "Build & Run Project",
				-- ft = ios_fts,
			},

			{
				"<localleader>xt",
				"<cmd>XcodebuildTest<cr>",
				mode = { "n" },
				desc = "Run Tests",
				-- ft = ios_fts
			},
			{
				"<localleader>xt",
				"<cmd>XcodebuildTestSelected<cr>",
				mode = { "v" },
				desc = "Run Selected Tests",
				-- ft = ios_fts,
			},
			{
				"<localleader>xT",
				"<cmd>XcodebuildTestClass<cr>",
				mode = { "n" },
				desc = "Run Current Test Class",
				-- ft = ios_fts,
			},
			{
				"<localleader>x.",
				"<cmd>XcodebuildTestRepeat<cr>",
				mode = { "n" },
				desc = "Repeat Last Test Run",
				-- ft = ios_fts,
			},

			{
				"<localleader>xl",
				"<cmd>XcodebuildToggleLogs<cr>",
				mode = { "n" },
				desc = "Toggle Xcodebuild Logs",
				-- ft = ios_fts,
			},
			{
				"<localleader>xc",
				"<cmd>XcodebuildToggleCodeCoverage<cr>",
				mode = { "n" },
				desc = "Toggle Code Coverage",
				-- ft = ios_fts,
			},
			{
				"<localleader>xC",
				"<cmd>XcodebuildShowCodeCoverageReport<cr>",
				mode = { "n" },
				desc = "Show Code Coverage Report",
				-- ft = ios_fts,
			},
			{
				"<localleader>xe",
				"<cmd>XcodebuildTestExplorerToggle<cr>",
				mode = { "n" },
				desc = "Toggle Test Explorer",
				-- ft = ios_fts,
			},
			{
				"<localleader>xs",
				"<cmd>XcodebuildFailingSnapshots<cr>",
				mode = { "n" },
				desc = "Show Failing Snapshots",
				-- ft = ios_fts,
			},

			{
				"<localleader>xp",
				-- TODO: Add hot reload here
				"<cmd>XcodebuildPreviewGenerateAndShow hotReload<cr>",
				mode = { "n" },
				desc = "Generate Preview",
				-- ft = ios_fts,
			},
			{
				"<localleader>x<cr>",
				"<cmd>XcodebuildPreviewToggle<cr>",
				mode = { "n" },
				desc = "Toggle Preview",
				-- ft = ios_fts,
			},

			{
				"<localleader>xd",
				"<cmd>XcodebuildSelectDevice<cr>",
				mode = { "n" },
				desc = "Select Device",
				-- ft = ios_fts,
			},
			{
				"<localleader>xq",
				"<cmd>Telescope quickfix<cr>",
				mode = { "n" },
				desc = "Show QuickFix List",
				-- ft = ios_fts,
			},

			{
				"<localleader>xx",
				"<cmd>XcodebuildQuickfixLine<cr>",
				mode = { "n" },
				desc = "Quickfix Line",
				-- ft = ios_fts,
			},
			{
				"<localleader>xa",
				"<cmd>XcodebuildCodeActions<cr>",
				mode = { "n" },
				desc = "Show Code Actions",
				-- ft = ios_fts,
			},
		},
	},
	{
		"telescope.nvim",
		lazy = true,
		-- FIXME: Make better
		event = "DeferredUIEnter",
		before = function()
			require("lz.n").trigger_load("plenary.nvim")
		end,
		after = function()
			require("telescope").setup()
		end,
	},
	{
		"fidget.nvim",
		event = "DeferredUIEnter",
		after = function()
			local opts = {
				notification = {
					window = {
						normal_hl = "String", -- Base highlight group in the notification window
						winblend = 0, -- Background color opacity in the notification window
						border = "rounded", -- Border around the notification window
						zindex = 45, -- Stacking priority of the notification window
						max_width = 0, -- Maximum width of the notification window
						max_height = 0, -- Maximum height of the notification window
						x_padding = 1, -- Padding from right edge of window boundary
						y_padding = 1, -- Padding from bottom edge of window boundary
						align = "bottom", -- How to align the notification window
						relative = "editor", -- What the notification window position is relative to
					},
				},
			}
			require("fidget").setup(opts)
		end,
	},
}

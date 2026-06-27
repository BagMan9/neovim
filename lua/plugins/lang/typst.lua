return {
	{
		"typst-preview.nvim",
		build = {
			useNixpkgs = "typst-preview-nvim",
		},
		extraPackages = {
			"websocat",
		},
		lazy = false,
		opts = {
			open_cmd = "open %s",
			dependencies_bin = {
				tinymist = vim.fn.exepath("tinymist"),
				websocat = vim.fn.exepath("websocat"),
			},
		},
		after = function(_, opts)
			require("typst-preview").setup(opts)
		end,
	},
	{
		"nvim-lspconfig",
		extraPackages = {
			"tinymist",
			"typst",
		},
		opts = {
			servers = {
				["tinymist"] = {
					enable = true,
					keys = {
						{ "<localleader>pp", "<Cmd>TypstPreview<CR>", mode = { "n" }, desc = "Start Preview" },
						{ "<localleader>pt", "<Cmd>TypstPreviewToggle<CR>", mode = { "n" }, desc = "Toggle Preview" },
						{
							"<localleader>pc",
							"<Cmd>TypstPreviewFollowCursorToggle<CR>",
							mode = { "n" },
							desc = "Toggle Follow Cursor",
						},
						{ "<localleader>pC", "<Cmd>TypstPreviewSyncCursor<CR>", mode = { "n" }, desc = "Sync Cursor" },
					},
					settings = {
						formatterMode = "typstyle",
						exportPdf = "onType",
						-- semanticTokens = "enable",
					},
				},
			},
			setup = {
				-- tinymist = function()
				-- 	Utils.lsp.on_attach(function(client, bufnr)
				-- 		vim.keymap.set("n", "<localleader>tp", function()
				-- 			client:exec_cmd({
				-- 				title = "pin",
				-- 				command = "tinymist.pinMain",
				-- 				arguments = { vim.api.nvim_buf_get_name(0) },
				-- 			}, { bufnr = bufnr })
				-- 		end, { desc = "[T]inymist [P]in", noremap = true })
				--
				-- 		vim.keymap.set("n", "<localleader>tu", function()
				-- 			client:exec_cmd({
				-- 				title = "unpin",
				-- 				command = "tinymist.pinMain",
				-- 				arguments = { vim.v.null },
				-- 			}, { bufnr = bufnr })
				-- 		end, { desc = "[T]inymist [U]npin", noremap = true })
				-- 	end, "tinymist")
				-- end,
			},
		},
	},
}

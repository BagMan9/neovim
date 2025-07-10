---@class MyVim.intellisense
local M = {}

setmetatable(M, {
	__call = function(m, ...)
		return m.setup(...)
	end,
})

M._dynamic_keys = nil

function M.get()
	if M._dynamic_keys then
		return M._dynamic_keys
	end

	M._dynamic_keys = {
		{
			"<leader>cl",
			function()
				require("snacks").picker.lsp_config()
			end,
			desc = "Lsp Info",
		},
		{
			"gd",
			function()
				require("snacks").picker.lsp_definitions()
			end,
			desc = "Goto Definition",
			has = "definition",
		},
		{
			"gr",
			function()
				require("snacks").picker.lsp_references()
			end,
			desc = "References",
			nowait = true,
		},
		{
			"gI",
			function()
				require("snacks").picker.lsp_implementations()
			end,
			desc = "Goto Implementation",
		},
		{
			"gy",
			function()
				require("snacks").picker.lsp_type_definitions()
			end,
			desc = "Goto T[y]pe Definition",
		},
		{
			"<leader>cr",
			function()
				return ":IncRename" .. " " .. vim.fn.expand("<cword>")
			end,
			expr = true,
			desc = "Rename (inc-rename.nvim)",
			has = "rename",
			-- needs = "inc-rename.nvim",
		},
		{ "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
		{
			"<leader>ss",
			function()
				require("snacks").picker.lsp_symbols({ filter = Utils.lazy_defaults.kind_filter })
			end,
			desc = "LSP Symbols",
			has = "documentSymbol",
		},
		{
			"<leader>sS",
			function()
				require("snacks").picker.lsp_workspace_symbols({
					filter = Utils.lazy_defaults.kind_filter,
				})
			end,
			desc = "LSP Workspace Symbols",
			has = "workspace/symbols",
		},
		{
			"K",
			function()
				return vim.lsp.buf.hover()
			end,
			desc = "Hover",
		},
		{
			"gK",
			function()
				return vim.lsp.buf.signature_help()
			end,
			desc = "Signature Help",
			has = "signatureHelp",
		},
		{
			"<c-k>",
			function()
				return vim.lsp.buf.signature_help()
			end,
			mode = "i",
			desc = "Signature Help",
			has = "signatureHelp",
		},
		{ "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" },
		{ "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" }, has = "codeLens" },
		{
			"<leader>cC",
			vim.lsp.codelens.refresh,
			desc = "Refresh & Display Codelens",
			mode = { "n" },
			has = "codeLens",
		},
		{
			"<leader>cR",
			function()
				require("snacks").rename.rename_file()
			end,
			desc = "Rename File",
			mode = { "n" },
			has = { "workspace/didRenameFiles", "workspace/willRenameFiles" },
		},
		-- { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
		-- { "<leader>cA", LazyVim.lsp.action.source, desc = "Source Action", has = "codeAction" },
		{
			"]]",
			function()
				require("snacks").words.jump(vim.v.count1)
			end,
			has = "documentHighlight",
			desc = "Next Reference",
			cond = function()
				return require("snacks").words.is_enabled()
			end,
		},
		{
			"[[",
			function()
				require("snacks").words.jump(-vim.v.count1)
			end,
			has = "documentHighlight",
			desc = "Prev Reference",
			cond = function()
				return require("snacks").words.is_enabled()
			end,
		},
		{
			"<a-n>",
			function()
				require("snacks").words.jump(vim.v.count1, true)
			end,
			has = "documentHighlight",
			desc = "Next Reference",
			cond = function()
				return require("snacks").words.is_enabled()
			end,
		},
		{
			"<a-p>",
			function()
				require("snacks").words.jump(-vim.v.count1, true)
			end,
			has = "documentHighlight",
			desc = "Prev Reference",
			cond = function()
				return require("snacks").words.is_enabled()
			end,
		},
	}
	return M._dynamic_keys
end

function M.init_keys()
	Utils.lsp.on_attach(function(client, buffer)
		Utils.lsp.keys.on_attach(client, buffer)
	end)

	Utils.lsp.on_dynamic_capability(Utils.lsp.keys.on_attach)
end

return M

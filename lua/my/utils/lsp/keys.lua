---@class my.util.lsp.keys
local M = {}

---@param method string|string[]
function M.has(buffer, method)
	if type(method) == "table" then
		for _, m in ipairs(method) do
			if M.has(buffer, m) then
				return true
			end
		end
		return false
	end
	method = method:find("/") and method or "textDocument/" .. method
	local clients = Utils.lsp.get_clients({ bufnr = buffer })
	for _, client in ipairs(clients) do
		---@diagnostic disable-next-line
		if client.supports_method(method) then
			return true
		end
	end
	return false
end

M._keys = nil

function M.get()
	if M._keys then
		return M._keys
	end
    -- stylua: ignore
    M._keys =  {
      { "<leader>cl", function() require("snacks").picker.lsp_config() end, desc = "Lsp Info" },
      { "gd", function()
						require("snacks").picker.lsp_definitions()
					end, desc = "Goto Definition", has = "definition" },
      { "gr", function()
						require("snacks").picker.lsp_references()
					end, desc = "References", nowait = true },
      { "gI", function()
						require("snacks").picker.lsp_implementations()
					end, desc = "Goto Implementation" },
      { "gy", function()
						require("snacks").picker.lsp_type_definitions()
					end, desc = "Goto T[y]pe Definition" },
      {
				"<leader>cr",
				function()
          local inc_rename = require("inc_rename")
					return ":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>")
				end,
				expr = true,
				desc = "Rename (inc-rename.nvim)",
        has = "rename",
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
      { "K", function() return vim.lsp.buf.hover() end, desc = "Hover" },
      { "gK", function() return vim.lsp.buf.signature_help() end, desc = "Signature Help", has = "signatureHelp" },
      { "<c-k>", function() return vim.lsp.buf.signature_help() end, mode = "i", desc = "Signature Help", has = "signatureHelp" },
      { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" }, has = "codeAction" },
      { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "v" }, has = "codeLens" },
      { "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" }, has = "codeLens" },
      { "<leader>cR", function() require("snacks").rename.rename_file() end, desc = "Rename File", mode ={"n"}, has = { "workspace/didRenameFiles", "workspace/willRenameFiles" } },
      -- { "<leader>cr", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
      -- { "<leader>cA", LazyVim.lsp.action.source, desc = "Source Action", has = "codeAction" },
      { "]]", function() require("snacks").words.jump(vim.v.count1) end, has = "documentHighlight",
        desc = "Next Reference", cond = function() return require("snacks").words.is_enabled() end },
      { "[[", function() require("snacks").words.jump(-vim.v.count1) end, has = "documentHighlight",
        desc = "Prev Reference", cond = function() return require("snacks").words.is_enabled() end },
      { "<a-n>", function() require("snacks").words.jump(vim.v.count1, true) end, has = "documentHighlight",
        desc = "Next Reference", cond = function() return require("snacks").words.is_enabled() end },
      { "<a-p>", function() require("snacks").words.jump(-vim.v.count1, true) end, has = "documentHighlight",
        desc = "Prev Reference", cond = function() return require("snacks").words.is_enabled() end },
    }

	return M._keys
end

function M.resolve(buffer)
	-- I don't care about global keys, I can do my own, add global checks latter
	local specs = M.get()
	return specs
end

---@alias VimKeySpec {lhs:string,rhs:string|fun():string?|false,mode:string|string[],opts?:vim.keymap.set.Opts}

---@param key KeysSpec
---@return VimKeySpec
function M.key_format(key)
	local fmt = {
		lhs = key[1],
		rhs = key[2],
		mode = "n",
		opts = {},
	}
	if key.mode then
		fmt.mode = key.mode
	end

	for k, v in pairs(key) do
		if type(k) ~= "number" and k ~= "mode" and k ~= "has" and k ~= "cond" then
			fmt.opts[k] = v
		end
	end
	return fmt
end

function M.on_attach(_, buffer)
	local keymaps = M.resolve(buffer)

	for _, keys in ipairs(keymaps) do
		local has = not keys.has or M.has(buffer, keys.has)
		local cond = not (keys.cond == false or ((type(keys.cond) == "function") and not keys.cond()))
		if has and cond then
			local k_fmt = M.key_format(keys)
			vim.keymap.set(k_fmt.mode, k_fmt.lhs, k_fmt.rhs, k_fmt.opts)
		end
	end
end

return M

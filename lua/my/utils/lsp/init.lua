---@class MyVim.util.lsp
---@field keys MyVim.util.lsp.keys
local M = {}

setmetatable(M, {
	__index = function(t, k)
		t[k] = require("my.utils.lsp." .. k)
		return t[k]
	end,
})

---@type table<string, table<vim.lsp.Client, table<number, boolean>>>
M._supports_method = {}

---@alias lsp.Client.filter {id?: number, bufnr?: number, name?: string, method?: string, filter?:fun(client: vim.lsp.Client):boolean}
---@param opts? lsp.Client.filter
function M.get_clients(opts)
	local ret = {} ---@type vim.lsp.Client[]
	if vim.lsp.get_clients then
		ret = vim.lsp.get_clients(opts)
	else
		---@diagnostic disable-next-line: deprecated
		ret = vim.lsp.get_active_clients(opts)
		if opts and opts.method then
			---@param client vim.lsp.Client
			ret = vim.tbl_filter(function(client)
				---@diagnostic disable-next-line
				return client.supports_method(opts.method, { bufner = opts.bufnr })
			end, ret)
		end
	end
	return opts and opts.filter and vim.tbl_filter(opts.filter, ret) or ret
end

function M.setup()
	local real_register_capability = vim.lsp.handlers["client/registerCapabilitity"]
	vim.lsp.handlers["client/registerCapabilitity"] = function(err, res, ctx)
		local ret = real_register_capability(err, res, ctx)
		local client = vim.lsp.get_client_by_id(ctx.client_id)
		if client then
			for buffer in pairs(client.attached_buffers) do
				vim.api.nvim_exec_autocmds("User", {
					pattern = "LspDynamicCapability",
					data = { client_id = client.id, buffer = buffer },
				})
			end
		end
		return ret
	end
	M.on_attach(M._check_methods)
	M.on_dynamic_capability(M._check_methods)
end

---@param client vim.lsp.Client
---@param buffer number
function M._check_methods(client, buffer)
	-- don't trigger on invalid buffers
	if not vim.api.nvim_buf_is_valid(buffer) then
		return
	end
	-- don't trigger on non-listed buffers
	if not vim.bo[buffer].buflisted then
		return
	end
	-- don't trigger on nofile buffers
	if vim.bo[buffer].buftype == "nofile" then
		return
	end
	for method, clients in pairs(M._supports_method) do
		clients[client] = clients[client] or {}
		if not clients[client][buffer] then
			-- NOTE: Again, might need changing!
			---@diagnostic disable-next-line
			if client.supports_method and client.supports_method(method, { bufnr = buffer }) then
				clients[client][buffer] = true
				vim.api.nvim_exec_autocmds("User", {
					pattern = "LspSupportsMethod",
					data = { client_id = client.id, buffer = buffer, method = method },
				})
			end
		end
	end
end

---@param on_attach fun(client:vim.lsp.Client,buffer:number)
---@param name? string
function M.on_attach(on_attach, name)
	return vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local buffer = args.buf
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			if client and (not name or client.name == name) then
				return on_attach(client, buffer)
			end
		end,
	})
end

---@param fn fun(client:vim.lsp.Client, buffer):boolean?
---@param opts? {group?: integer}
function M.on_dynamic_capability(fn, opts)
	return vim.api.nvim_create_autocmd("User", {
		pattern = "LspDynamicCapability",
		group = opts and opts.group or nil,
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			local buffer = args.data.buffer ---@type number
			if client then
				return fn(client, buffer)
			end
		end,
	})
end

---@param method string
---@param fn fun(client:vim.lsp.Client, buffer)
function M.on_supports_method(method, fn)
	M._supports_method[method] = M._supports_method[method] or setmetatable({}, { __mode = "k" })
	return vim.api.nvim_create_autocmd("User", {
		pattern = "LspSupportsMethod",
		callback = function(args)
			local client = vim.lsp.get_client_by_id(args.data.client_id)
			local buffer = args.data.buffer ---@type number
			if client and method == args.data.method then
				return fn(client, buffer)
			end
		end,
	})
end

-- Formatting
---@alias lsp.Client.format {timeout_ms?: number, format_options?: table} | lsp.Client.filter

---@param opts? lsp.Client.format
function M.format(opts)
	local ok, conform = pcall(require, "conform")
	-- use conform for formatting with LSP when available,
	-- since it has better format diffing
	if ok then
		--NOTE: This will probably fail at some point!!
		-- opts.formatters = {}
		conform.format(opts)
	else
		vim.lsp.buf.format(opts)
	end
end

---@param opts? Formatter | {filter?: (string|lsp.Client.filter)}
function M.formatter(opts)
	opts = opts or {}
	local filter = opts.filter or {}
	filter = type(filter) == "string" and { name = filter } or filter
	---@cast filter lsp.Client.filter
	---@type Formatter
	local ret = {
		name = "LSP",
		primary = true,
		priority = 1,
		format = function(buf)
			-- This is probably non-functional right now
			M.format(filter) -- , { bufnr = buf }
		end,
		sources = function(buf)
			-- Again, non-functional
			local clients = M.get_clients({ bufner = buf })
			---@param client vim.lsp.Client
			local ret = vim.tbl_filter(function(client)
				---@diagnostic disable-next-line
				return client.supports_method("textDocument/formatting")
					---@diagnostic disable-next-line
					or client.supports_method("textDocument/rangeFormatting")
			end, clients)
			---@param client vim.lsp.Client
			return vim.tbl_map(function(client)
				return client.name
			end, ret)
		end,
	}
	return ret --[[@as Formatter]]
end
return M

---@class MyVim.util.lsp.keys
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

function M.resolve(buffer)
	local specs = MyVim.intellisense.get()

	local lsp_plugin = require("lzl.config").spec.plugins["nvim-lspconfig"]
	local lsp_conf = require("lzl.plugin").values(lsp_plugin, "opts", false)
	local clients = Utils.lsp.get_clients({ bufnr = buffer })
	for _, client in ipairs(clients) do
		local maps = lsp_conf.servers[client.name] and lsp_conf.servers[client.name].keys or {}
		vim.list_extend(specs, maps)
	end
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
		if type(k) ~= "number" and k ~= "mode" and k ~= "has" and k ~= "cond" and k ~= "needs" then
			fmt.opts[k] = v
		end
	end
	return fmt
end

function M.on_attach(_, buffer)
	local keymaps = M.resolve(buffer)
	local to_load = {}
	for _, keys in ipairs(keymaps) do
		local has = not keys.has or M.has(buffer, keys.has)
		local cond = not (keys.cond == false or ((type(keys.cond) == "function") and not keys.cond()))
		local load = keys.load
		if has and cond then
			local k_fmt = M.key_format(keys)
			vim.keymap.set(k_fmt.mode, k_fmt.lhs, k_fmt.rhs, k_fmt.opts)
			if load then
				to_load[#to_load + 1] = keys.load
			end
		end
	end

	if to_load ~= {} then
		require("lz.n").trigger_load(to_load)
	end
end

return M

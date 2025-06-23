---@class MyVim.util.format
---@overload fun(opts?: {force?:boolean})
local M = setmetatable({}, {
	__call = function(m, ...)
		return m.format(...)
	end,
})
---@class Formatter
---@field name string
---@field primary? boolean
---@field format fun(bufnum:number)
---@field sources fun(bufnum:number):string[]
---@field priority number

M.formatters = {} ---@type Formatter[]

---@param formatter Formatter
function M.add(formatter)
	M.formatters[#M.formatters + 1] = formatter
	table.sort(M.formatters, function(a, b)
		return a.priority > b.priority
	end)
end

---@param buf? number
---@return (Formatter|{active:boolean,resolved:string[]})[]
function M.buf_formatters(buf)
	buf = buf or vim.api.nvim_get_current_buf()
	local have_primary = false
	---@param formatter Formatter
	return vim.tbl_map(function(formatter)
		local sources = formatter.sources(buf)
		local active = #sources > 0 and (not formatter.primary or not have_primary)
		have_primary = have_primary or (active and formatter.primary) or false
		return setmetatable({
			active = active,
			resolved = sources,
		}, { __index = formatter })
	end, M.formatters)
end

---@param buf? number
function M.buf_enabled(buf)
	buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
	local gaf = vim.g.autoformat
	local baf = vim.b[buf].autoformat

	-- If the buffer has a local value, use that
	if baf ~= nil then
		return baf
	end

	-- Otherwise use the global value if set, or true by default
	return gaf == nil or gaf
end

---@param opts? {force?:boolean, buf?:number}
function M.format(opts)
	opts = opts or {}
	local buf = opts.buf or vim.api.nvim_get_current_buf()
	if not ((opts and opts.force) or M.buf_enabled(buf)) then
		return
	end
	local done = false
	for _, formatter in ipairs(M.buf_formatters(buf)) do
		if formatter.active then
			done = true
			Utils.try(function()
				return formatter.format(buf)
			end, { msg = "Formatter `" .. formatter.name .. "` failed" })
		end
	end

	if not done and opts and opts.force then
		Utils.warn("No formatter available")
	end
end

---@return nil
function M.setup(opts)
	require("conform").setup(opts)

	vim.api.nvim_create_autocmd("BufWritePre", {
		group = vim.api.nvim_create_augroup("Format", {}),
		callback = function(event)
			M.format({ buf = event.buf })
		end,
	})

	vim.api.nvim_create_user_command("Format", function()
		M.format({ force = true })
	end, { desc = "Format selection or buffer" })
end

return M

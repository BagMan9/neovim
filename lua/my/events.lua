---@class MyVim.lazyfile
local M = {}

function M.trigger_event(opts)
	if opts.group or opts.exclude == nil then
		M._trigger_event(opts)
	end
	local done = {}
	for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ event = opts.event })) do
		local id = autocmd.event .. ":" .. (autocmd.group or "")
		local skip = done[id] or (opts.exclude and vim.tbl_contains(opts.exclude, autocmd.group_name))
		done[id] = true
		if autocmd.group and not skip then
			opts.group = autocmd.group_name
			M._trigger_event(opts)
		end
	end
end
---@param event string
function M.getaugroups(event)
	local groups = {}
	for _, autocmd in ipairs(vim.api.nvim_get_autocmds({ event = event })) do
		if autocmd.group_name then
			table.insert(groups, autocmd.group_name)
		end
	end
	return groups
end

function M._trigger_event(opts)
	vim.api.nvim_exec_autocmds(opts.event, {
		buffer = opts.buffer,
		group = opts.group,
		modeline = false,
		data = opts.data,
	})
end

function M.init_lazy_file()
	local events = {} ---@type {event: string, buf: number, data?: any}[]
	local done = false

	local function load()
		if #events == 0 or done then
			return
		end
		done = true

		vim.api.nvim_del_augroup_by_name("lazy_file")

		---@type table<string,string[]>
		local skips = {}
		for _, event in ipairs(events) do
			skips[event.event] = skips[event.event] or M.getaugroups(event.event)
		end
		vim.api.nvim_exec_autocmds("User", { pattern = "LazyFile", modeline = false })
		for _, event in ipairs(events) do
			if vim.api.nvim_buf_is_valid(event.buf) then
				M.trigger_event({
					event = event.event,
					exclude = skips[event.event],
					data = event.data,
					buf = event.buf,
				})
				if vim.bo[event.buf].filetype then
					M.trigger_event({
						event = "Filetype",
						buf = event.buf,
					})
				end
			end
		end

		vim.api.nvim_exec_autocmds("CursorMoved", { modeline = false })
		events = {}
	end

	load = vim.schedule_wrap(load)

	vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "BufNewFile" }, {
		group = vim.api.nvim_create_augroup("lazy_file", { clear = true }),
		callback = function(event)
			table.insert(events, event)
			load()
		end,
	})
end

return M

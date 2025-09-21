---@class LzlUtilCore
local M = {}

---@alias LzlProfile {data: string|{[string]:string}, time: number, [number]:LzlProfile}
---
---@type LzlProfile[]
M._profiles = { { name = "lzl" } }

---@param data (string|{[string]:string})?
---@param time number?
function M.track(data, time)
	if data then
		local entry = {
			data = data,
			---@diagnostic disable-next-line: undefined-field
			time = time or vim.uv.hrtime(),
		}
		table.insert(M._profiles[#M._profiles], entry)

		if not time then
			table.insert(M._profiles, entry)
		end
		return entry
	else
		---@type LzlProfile
		local entry = table.remove(M._profiles)
		---@diagnostic disable-next-line: undefined-field
		entry.time = vim.uv.hrtime() - entry.time
		return entry
	end
end

function M.lsmod(modname, fn)
	local root, match = M.find_root(modname)
	if not root then
		return
	end

	if match:sub(-4) == ".lua" then
		fn(modname, match)
		---@diagnostic disable-next-line: undefined-field
		if not vim.uv.fs_stat(root) then
			return
		end
	end

	M.ls(root, function(path, name, type)
		if name == "init.lua" then
			fn(modname, path)
		elseif (type == "file" or type == "link") and name:sub(-4) == ".lua" then
			fn(modname .. "." .. name:sub(1, -5), path)
		elseif type == "directory" and vim.uv.fs_stat(path .. "/init.lua") then
			fn(modname .. "." .. name, path .. "/init.lua")
		end
	end)
end

function M.get_source()
	local f = 2
	while true do
		local info = debug.getinfo(f, "S")
		if not info then
			break
		end
		if info.what ~= "C" and not info.source:find("lazy.nvim", 1, true) and info.source ~= "@vim/loader.lua" then
			return info.source:sub(2)
		end
		f = f + 1
	end
end

function M.very_lazy()
	local function _load()
		vim.schedule(function()
			if vim.v.exiting ~= vim.NIL then
				return
			end
			vim.g.did_very_lazy = true
			M.track({ event = "VeryLazy" })
			vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy", modeline = false })
			M.track()
		end)
	end

	vim.api.nvim_create_autocmd("User", {
		pattern = "LazyDone",
		once = true,
		callback = function()
			if vim.v.vim_did_enter == 1 then
				_load()
			else
				vim.api.nvim_create_autocmd("UIEnter", {
					once = true,
					callback = function()
						_load()
					end,
				})
			end
		end,
	})
end

---@param t table
function M.is_list(t)
	local i = 0
	---@diagnostic disable-next-line: no-unknown
	for _ in pairs(t) do
		i = i + 1
		if t[i] == nil then
			return false
		end
	end
	return true
end

---@generic T
---@param list T[]
---@param fn fun(v: T):boolean?
---@return T[]
function M.filter(fn, list)
	local ret = {}
	for _, v in ipairs(list) do
		if fn(v) then
			table.insert(ret, v)
		end
	end
	return ret
end

---@generic R
---@param fn fun():R?
---@param opts? string|{msg:string, on_error:fun(msg)}
---@return R
function M.try(fn, opts)
	opts = type(opts) == "string" and { msg = opts } or opts or {}
	local msg = opts.msg
	-- error handler
	local error_handler = function(err)
		msg = (msg and (msg .. "\n\n") or "") .. err .. M.pretty_trace()
		if opts.on_error then
			opts.on_error(msg)
		else
			vim.schedule(function()
				M.error(msg)
			end)
		end
		return err
	end

	---@type boolean, any
	local ok, result = xpcall(fn, error_handler)
	return ok and result or nil
end

---@alias FileType "file"|"directory"|"link"
---@param path string
---@param fn fun(path: string, name:string, type:FileType):boolean?
function M.ls(path, fn)
	---@diagnostic disable-next-line: undefined-field
	local handle = vim.uv.fs_scandir(path)
	while handle do
		---@diagnostic disable-next-line: undefined-field
		local name, t = vim.uv.fs_scandir_next(handle)
		if not name then
			break
		end

		local fname = path .. "/" .. name

		-- HACK: type is not always returned due to a bug in luv,
		-- so fecth it with fs_stat instead when needed.
		-- see https://github.com/folke/lazy.nvim/issues/306
		--
		---@diagnostic disable-next-line: undefined-field
		if fn(fname, name, t or vim.uv.fs_stat(fname).type) == false then
			break
		end
	end
end

---@param path string
---@param fn fun(path: string, name:string, type:FileType)
function M.walk(path, fn)
	M.ls(path, function(child, name, type)
		-- local realtype = type
		-- local realchild = child
		-- while realtype == "link" do
		-- 	---@diagnostic disable-next-line: undefined-field
		-- 	realchild = vim.uv.fs_readlink(child)
		-- 	---@diagnostic disable-next-line: undefined-field
		-- 	realtype = vim.uv.fs_stat(child).type
		-- end
		if type == "directory" then
			M.walk(child, fn)
		end
		fn(child, name, type)
	end)
end

---@param root string
---@param fn fun(modname:string, modpath:string)
---@param modname? string
function M.walkmods(root, fn, modname)
	modname = modname and (modname:gsub("%.$", "") .. ".") or ""
	M.ls(root, function(path, name, type)
		if name == "init.lua" then
			fn(modname:gsub("%.$", ""), path)
		elseif (type == "file" or type == "link") and name:sub(-4) == ".lua" then
			fn(modname .. name:sub(1, -5), path)
		elseif type == "directory" then
			M.walkmods(path, fn, modname .. name .. ".")
		end
	end)
end

---@param modname string
---@return string
function M.topmod(modname)
	return modname:match("^[^./]+") or modname
end

---@type table<string, string[]>
M.unloaded_cache = {}

---@param modname string
---@param opts? {cache?:boolean}
function M.get_unloaded_rtp(modname, opts)
	opts = opts or {}

	local topmod = M.topmod(modname)
	if opts.cache and M.unloaded_cache[topmod] then
		return M.unloaded_cache[topmod], true
	end

	local norm = M.normname(topmod)

	---@type string[]
	local rtp = {}
	local Config = require("lzl.config")
	if Config.spec then
		for _, plugin in pairs(Config.spec.plugins) do
			if not plugin._.loaded then
				if norm == M.normname(plugin.name) then
					table.insert(rtp, 1, plugin.dir)
				else
					table.insert(rtp, plugin.dir)
				end
			end
		end
	end
	M.unloaded_cache[topmod] = rtp
	return rtp, false
end

---@param name string
---@return string
function M.normname(name)
	local ret = name:lower():gsub("^n?vim%-", ""):gsub("%.n?vim$", ""):gsub("[%.%-]lua", ""):gsub("[^a-z]+", "")
	return ret
end

function M.norm(path)
	if path:sub(1, 1) == "~" then
		---@diagnostic disable-next-line: undefined-field
		local home = vim.uv.os_homedir()
		if home:sub(-1) == "\\" or home:sub(-1) == "/" then
			home = home:sub(1, -2)
		end
		path = home .. path:sub(2)
	end
	path = path:gsub("\\", "/"):gsub("/+", "/")
	return path:sub(-1) == "/" and path:sub(1, -2) or path
end

function M.pretty_trace(opts)
	opts = opts or {}
	local Config = require("lazy.core.config")
	local trace = {}
	local level = opts.level or 2
	while true do
		local info = debug.getinfo(level, "Sln")
		if not info then
			break
		end
		if info.what ~= "C" and (Config.options.debug or not info.source:find("lazy.nvim")) then
			local source = info.source:sub(2)
			if source:find(Config.options.root, 1, true) == 1 then
				source = source:sub(#Config.options.root + 1)
			end
			source = vim.fn.fnamemodify(source, ":p:~:.") --[[@as string]]
			local line = "  - " .. source .. ":" .. info.currentline
			if info.name then
				line = line .. " _in_ **" .. info.name .. "**"
			end
			table.insert(trace, line)
		end
		level = level + 1
	end
	return #trace > 0 and ("\n\n# stacktrace:\n" .. table.concat(trace, "\n")) or ""
end

local function can_merge(v)
	return type(v) == "table" and (vim.tbl_isempty(v) or not M.is_list(v))
end

---@generic T
---@param ... T
---@return T
function M.merge(...)
	local ret = select(1, ...)
	if ret == vim.NIL then
		ret = nil
	end
	for i = 2, select("#", ...) do
		local value = select(i, ...)
		if can_merge(ret) and can_merge(value) then
			for k, v in pairs(value) do
				ret[k] = M.merge(ret[k], v)
			end
		elseif value == vim.NIL then
			ret = nil
		elseif value ~= nil then
			ret = value
		end
	end
	return ret
end

---@generic T
---@param list T[]
---@param add T[]
---@return T[]
function M.extend(list, add)
	local idx = {}
	for _, v in ipairs(list) do
		idx[v] = v
	end
	for _, a in ipairs(add) do
		if not idx[a] then
			table.insert(list, a)
		end
	end
	return list
end

function M.find_root(modname)
	local paths, cached = M.get_unloaded_rtp(modname, { cache = true })

	local ret = vim.loader.find(modname, {
		rtp = true,
		paths = paths,
		patterns = { ".lua", "" },
	})[1]

	if not ret and cached then
		paths = M.get_unloaded_rtp(modname)
		ret = vim.loader.find(modname, {
			rtp = false,
			paths = paths,
			patterns = { ".lua", "" },
		})[1]
	end
	if ret then
		return ret.modpath:gsub("%.lua$", ""), ret.modpath
	end
end

-- Notify stuff
---@alias LzlNotifyOpts {lang?:string, title?:string, level?:number, once?:boolean, stacktrace?:boolean, stacklevel?:number}

---@param msg string|string[]
---@param opts? LzlNotifyOpts
function M.notify(msg, opts)
	if vim.in_fast_event() then
		return vim.schedule(function()
			M.notify(msg, opts)
		end)
	end

	opts = opts or {}
	if type(msg) == "table" then
		msg = table.concat(
			vim.tbl_filter(function(line)
				return line or false
			end, msg),
			"\n"
		)
	end
	if opts.stacktrace then
		msg = msg .. M.pretty_trace({ level = opts.stacklevel or 2 })
	end
	local lang = opts.lang or "markdown"
	local n = opts.once and vim.notify_once or vim.notify
	n(msg, opts.level or vim.log.levels.INFO, {
		ft = lang,
		on_open = function(win)
			local ok = pcall(function()
				vim.treesitter.language.add("markdown")
			end)
			if not ok then
				pcall(require, "nvim-treesitter")
			end
			vim.wo[win].conceallevel = 3
			vim.wo[win].concealcursor = ""
			vim.wo[win].spell = false
			local buf = vim.api.nvim_win_get_buf(win)
			if not pcall(vim.treesitter.start, buf, lang) then
				vim.bo[buf].filetype = lang
				vim.bo[buf].syntax = lang
			end
		end,
		title = opts.title or "lzl",
	})
end

---@param msg string|string[]
---@param opts? LzlNotifyOpts
function M.error(msg, opts)
	opts = opts or {}
	opts.level = vim.log.levels.ERROR
	M.notify(msg, opts)
end

---@param msg string|string[]
---@param opts? LzlNotifyOpts
function M.info(msg, opts)
	opts = opts or {}
	opts.level = vim.log.levels.INFO
	M.notify(msg, opts)
end

---@param msg string|string[]
---@param opts? LzlNotifyOpts
function M.warn(msg, opts)
	opts = opts or {}
	opts.level = vim.log.levels.WARN
	M.notify(msg, opts)
end

---@param msg string|table
---@param opts? LzlNotifyOpts
function M.debug(msg, opts)
	if not require("lzl.config").options.debug then
		return
	end
	opts = opts or {}
	if opts.title then
		opts.title = "lzl: " .. opts.title
	end
	if type(msg) == "string" then
		M.notify(msg, opts)
	else
		opts.lang = "lua"
		M.notify(vim.inspect(msg), opts)
	end
end

---@param t table
---@param key string|string[]
---@return any
function M.key_get(t, key)
	---@diagnostic disable-next-line: param-type-mismatch
	local path = type(key) == "table" and key or vim.split(key, ".", true)
	local value = t
	for _, k in ipairs(path) do
		if type(value) ~= "table" then
			return value
		end
		value = value[k]
	end
	return value
end

---@param t table
---@param key string|string[]
---@param value any
function M.key_set(t, key, value)
	---@diagnostic disable-next-line: param-type-mismatch
	local path = type(key) == "table" and key or vim.split(key, ".", true)
	local last = t
	for i = 1, #path - 1 do
		local k = path[i]
		if type(last[k]) ~= "table" then
			last[k] = {}
		end
		last = last[k]
	end
	last[path[#path]] = value
end

return M

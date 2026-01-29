--- Export plugin specifications for npins/Nix consumption
--- Handles syncing plugin sources with npins and generating build metadata
local Config = require("lzl.config")
local Source = require("lzl.source")
local Util = require("lzl.util")

local M = {}

--- Default paths (can be overridden)
-- TODO: Make platform independent (stdpath doesn't work with mnw wrapper)
M.defaults = {
	-- Where npins sources.json lives (npins-controlled)
	npins_dir = "/Users/isaac/.config/nvim",
	-- Where we write our plugin metadata
	plugins_json = "/Users/isaac/.config/nvim/npins/plugins.json",
}

---@class LzlExportOpts
---@field npins_dir? string
---@field plugins_json? string
---@field dry_run? boolean

--- Read existing npins sources.json
---@param npins_dir string
---@return table<string, any>?
function M.read_npins_sources(npins_dir)
	local path = npins_dir .. "/npins/sources.json"
	local f = io.open(path, "r")
	if not f then
		return nil
	end
	local content = f:read("*a")
	f:close()

	local ok, data = pcall(vim.json.decode, content)
	if not ok then
		Util.error("Failed to parse " .. path .. ": " .. tostring(data))
		return nil
	end

	-- npins sources.json has a "pins" key
	return data.pins or data
end

--- Read existing plugins.json
---@param path string
---@return table<string, any>
function M.read_plugins_json(path)
	local f = io.open(path, "r")
	if not f then
		return {}
	end
	local content = f:read("*a")
	f:close()

	local ok, data = pcall(vim.json.decode, content)
	if not ok then
		Util.warn("Failed to parse " .. path .. ", starting fresh")
		return {}
	end
	return data
end

--- Write plugins.json
---@param path string
---@param data table
function M.write_plugins_json(path, data)
	-- Ensure directory exists
	local dir = vim.fn.fnamemodify(path, ":h")
	vim.fn.mkdir(dir, "p")

	local f = io.open(path, "w")
	if not f then
		Util.error("Failed to open " .. path .. " for writing")
		return false
	end

	-- Pretty print JSON
	local json = vim.json.encode(data)
	-- Simple pretty print - add newlines after { and before }
	json = vim.fn.system({ "jq", "." }, json)

	f:write(json)
	f:close()
	return true
end

--- Gather all plugins with source or useNixpkgs information
---@return table<string, {source?: LzlSource, extraPackages?: string[], build?: LzlBuildSpec, lzl_name: string, needs_npins: boolean}>
function M.gather_exportable_plugins()
	local plugins = {}

	if not Config.spec then
		Util.error("Config.spec not initialized. Run lzl_setup first.")
		return plugins
	end

	for name, plugin in pairs(Config.spec.plugins) do
		-- Walk the metatable chain to find source/build/extraPackages
		local source = nil
		local extraPackages = nil
		local build = nil
		local current = plugin

		while current do
			if rawget(current, "source") then
				source = rawget(current, "source")
			end
			if rawget(current, "extraPackages") then
				extraPackages = rawget(current, "extraPackages")
			end
			if rawget(current, "build") then
				build = rawget(current, "build")
			end

			local mt = getmetatable(current)
			current = mt and mt.__index or nil
		end

		-- Export if has source OR has useNixpkgs (for pure nixpkgs refs with metadata)
		local has_source = source ~= nil
		local has_use_nixpkgs = build and build.useNixpkgs

		if has_source or has_use_nixpkgs then
			local normalized_source = nil
			if has_source then
				normalized_source = Source.normalize(source, name)
			end

			local npins_name = Source.to_npins_name(name)
			plugins[npins_name] = {
				source = normalized_source,
				extraPackages = extraPackages,
				build = build,
				lzl_name = name,
				needs_npins = has_source, -- only add to npins if has source
			}
		end
	end

	return plugins
end

--- Initialize npins in the config directory if not present
---@param npins_dir string
---@param dry_run boolean
---@return boolean
function M.ensure_npins_init(npins_dir, dry_run)
	local sources_path = npins_dir .. "/npins/sources.json"
	---@diagnostic disable-next-line: undefined-field
	if vim.uv.fs_stat(sources_path) then
		return true
	end

	if dry_run then
		Util.info("[dry-run] Would run: npins init --bare in " .. npins_dir)
		return true
	end

	-- Create directory
	vim.fn.mkdir(npins_dir, "p")

	-- Run npins init --bare (no default nixpkgs)
	local result = vim.system({ "npins", "init", "--bare" }, { cwd = npins_dir }):wait()

	if result.code ~= 0 then
		Util.error("npins init failed: " .. (result.stderr or "unknown error"))

		return false
	end

	Util.info("Initialized npins in " .. npins_dir)
	return true
end

--- Run npins add command
---@param cmd string[]
---@param npins_dir string
---@param dry_run boolean
---@return boolean
function M.run_npins_add(cmd, npins_dir, dry_run)
	local cmd_str = table.concat(cmd, " ")

	if dry_run then
		Util.info("[dry-run] Would run: " .. cmd_str)
		return true
	end

	Util.info("Running: " .. cmd_str)
	local result = vim.system(cmd, { cwd = npins_dir }):wait()

	if result.code ~= 0 then
		Util.error("Command failed: " .. cmd_str .. "\n" .. (result.stderr or ""))
		if result.stderr:match("*tags*") then
			table.insert(cmd, "-b")
			table.insert(cmd, "master")

			local retry_result = vim.system(cmd, { cwd = npins_dir }):wait()
			if retry_result.code ~= 0 and retry_result.stderr:match("*tags*") then
				cmd[-1] = "main"
				retry_result = vim.system(cmd, { cwd = npins_dir }):wait()
				if retry_result.code ~= 0 then
					Util.error("Command failed: " .. cmd_str .. "\n" .. (result.stderr or ""))
				else
					return true
				end
			else
				return true
			end
		end
		return false
	end

	return true
end

--- Main export function
---@param opts? LzlExportOpts
function M.export(opts)
	opts = opts or {}
	-- Read from lzl config if available, fall back to defaults
	local export_config = Config.options and Config.options.export or {}
	local npins_dir = opts.npins_dir or export_config.npins_dir or M.defaults.npins_dir
	local plugins_json_path = opts.plugins_json or export_config.plugins_json or M.defaults.plugins_json
	local dry_run = opts.dry_run or false

	-- Ensure npins is initialized
	if not M.ensure_npins_init(npins_dir, dry_run) then
		return
	end

	-- Gather plugins with sources or useNixpkgs from lzl config
	local plugins = M.gather_exportable_plugins()

	if vim.tbl_isempty(plugins) then
		Util.info("No plugins with source or useNixpkgs specifications found")
		return
	end

	-- Read existing npins sources
	local existing_sources = M.read_npins_sources(npins_dir) or {}

	-- Track what we'll add to npins and what metadata to write
	local to_add = {}
	local plugins_meta = {}

	for npins_name, plugin_data in pairs(plugins) do
		-- Build metadata entry
		plugins_meta[npins_name] = {
			lzl_name = plugin_data.lzl_name,
		}
		if plugin_data.extraPackages then
			plugins_meta[npins_name].extraPackages = plugin_data.extraPackages
		end
		if plugin_data.build then
			if plugin_data.build.nvimSkipModules then
				plugins_meta[npins_name].nvimSkipModules = plugin_data.build.nvimSkipModules
			end
			if plugin_data.build.nixDeps then
				plugins_meta[npins_name].nixDeps = plugin_data.build.nixDeps
			end
			if plugin_data.build.useNixpkgs then
				plugins_meta[npins_name].useNixpkgs = plugin_data.build.useNixpkgs
			end
		end

		-- Only add to npins if plugin has a source (not pure useNixpkgs)
		if plugin_data.needs_npins and not existing_sources[npins_name] then
			to_add[npins_name] = plugin_data
		end
	end

	-- Report status
	local needs_npins_count = 0
	for _, data in pairs(plugins) do
		if data.needs_npins then
			needs_npins_count = needs_npins_count + 1
		end
	end
	local existing_count = needs_npins_count - vim.tbl_count(to_add)
	local nixpkgs_only_count = vim.tbl_count(plugins) - needs_npins_count

	Util.info(
		string.format(
			"Found %d exportable plugins (%d with sources: %d pinned, %d new; %d nixpkgs-only)",
			vim.tbl_count(plugins),
			needs_npins_count,
			existing_count,
			vim.tbl_count(to_add),
			nixpkgs_only_count
		)
	)

	-- Add new plugins to npins
	local added = 0
	local failed = 0
	for npins_name, plugin_data in pairs(to_add) do
		local cmd = Source.to_npins_command(plugin_data.source, npins_name)
		if M.run_npins_add(cmd, npins_dir, dry_run) then
			added = added + 1
		else
			failed = failed + 1
		end
	end

	if added > 0 or failed > 0 then
		Util.info(string.format("Added %d plugins to npins (%d failed)", added, failed))
	end

	-- Write plugins.json
	if not dry_run then
		if M.write_plugins_json(plugins_json_path, plugins_meta) then
			Util.info("Wrote plugin metadata to " .. plugins_json_path)
		end
	else
		Util.info("[dry-run] Would write plugins.json with " .. vim.tbl_count(plugins_meta) .. " entries")
	end
end

--- Setup the :LzlExport command
function M.setup_command()
	vim.api.nvim_create_user_command("LzlExport", function(cmd_opts)
		local dry_run = cmd_opts.bang
		M.export({ dry_run = dry_run })
	end, {
		desc = "Export plugin sources to npins and generate plugins.json",
		bang = true, -- :LzlExport! for dry-run
	})
end

return M

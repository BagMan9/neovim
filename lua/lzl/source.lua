--- Source specification parsing for lzl
--- Handles plugin source definitions (github, gitlab, git, etc.)
local M = {}

-- ---@class LzlSource
-- ---@field type "github"|"gitlab"|"git"
-- ---@field owner? string
-- ---@field repo string
-- ---@field branch? string
-- ---@field rev? string
--
-- ---@class LzlBuildSpec
-- ---@field nvimSkipModules? string[]
-- ---@field nixDeps? string[]

--- Normalize a source specification
--- Accepts either a table or nil (for nixpkgs fallback)
---@param source? LzlSource
---@param plugin_name string
---@return LzlSource?
function M.normalize(source, plugin_name)
	if source == nil then
		return nil
	end

	if type(source) ~= "table" then
		error("source must be a table for plugin " .. plugin_name)
	end

	-- Validate required fields based on type
	local t = source.type
	if not t then
		error("source.type is required for plugin " .. plugin_name)
	end

	if t == "github" or t == "gitlab" then
		if not source.owner then
			error("source.owner is required for " .. t .. " source in plugin " .. plugin_name)
		end
		if not source.repo then
			error("source.repo is required for " .. t .. " source in plugin " .. plugin_name)
		end
	elseif t == "git" then
		if not source.url then
			error("source.url is required for git source in plugin " .. plugin_name)
		end
	else
		error("Unknown source type: " .. t .. " for plugin " .. plugin_name)
	end

	return source
end

--- Convert a plugin name to an npins-friendly name
--- e.g., "octo.nvim" -> "octo-nvim"
---@param name string
---@return string
function M.to_npins_name(name)
	return name:gsub("%.", "-"):gsub("_", "-"):lower()
end

--- Convert an npins name back to a plugin name
--- This is a best-effort reverse mapping
---@param npins_name string
---@return string
function M.from_npins_name(npins_name)
	-- This is lossy - we can't know if it was . or _ originally
	-- The plugins.json will have the original name as a field
	return npins_name
end

--- Build the npins add command for a source
---@param source LzlSource
---@param npins_name string
---@return string[]
function M.to_npins_command(source, npins_name)
	local cmd = { "npins", "add" }

	if source.type == "github" then
		table.insert(cmd, "github")
		table.insert(cmd, source.owner)
		table.insert(cmd, source.repo)
	elseif source.type == "gitlab" then
		table.insert(cmd, "gitlab")
		table.insert(cmd, source.owner)
		table.insert(cmd, source.repo)
	elseif source.type == "git" then
		table.insert(cmd, "git")
		table.insert(cmd, source.url)
	end

	-- Add name override
	table.insert(cmd, "--name")
	table.insert(cmd, npins_name)

	-- Add optional branch
	if source.branch then
		table.insert(cmd, "--branch")
		table.insert(cmd, source.branch)
	end

	-- Add optional revision (for pinning)
	if source.rev then
		table.insert(cmd, "--at")
		table.insert(cmd, source.rev)
	end

	return cmd
end

return M

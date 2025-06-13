---@class MyVim
---@field plugins PrePluginSpec[]
---@field utils MyVim.util
---@field lsp MyVim.intellisense
---@field intellisense MyVim.intellisense
local M = {}
setmetatable(M, {
	__index = function(t, k)
		t[k] = require("my." .. k)
		return t[k]
	end,
})

---@type PrePluginSpec[]
M.plugins = {}

---@return nil
function M.init()
	M.pre_setup()
	MyVim.intellisense.init()
	local plugs = M.format_plugins()

	require("lz.n").load(plugs)
	require("lz.n").load("plugins")

	vim.cmd(":colorscheme catppuccin")

	require("my.autocmds")
	require("keymaps")
end

---@return lz.n.PluginSpec[]
function M.format_plugins()
	---@type PreFormat
	local preprocess = {}
	---@type lz.n.PluginSpec[]
	local processed = {}
	-- Make one spec per plugin
	for _, spec in ipairs(M.plugins) do
		local name = spec[1]
		preprocess[name] = vim.tbl_deep_extend("force", preprocess[name] or {}, spec)
	end
	---@param spec PrePluginSpec
	---@param name string
	---@return lz.n.PluginSpec
	local function create_spec(spec, name)
		---@type lz.n.PluginSpec
		local output = { name }
		if spec.enabled == false then
			return {}
		end
		if spec.opts then
			if spec.setup == false then
				Utils.warn("Opts for" .. name .. "included but setup disabled", { level = vim.log.levels.WARN })
			else
				if spec.setup == nil then
					output.after = function()
						local opts = spec.opts
						require(spec.req).setup(opts)
					end
				else
					output.after = function()
						spec.setup(spec.opts)
					end
				end
			end
		else
			output.after = spec.setup or nil
		end

		if spec.needs then
			output.before = function()
				require("lz.n").trigger_load(spec.needs)
				if spec.before then
					spec.before()
				end
			end
		else
			output.before = spec.before
		end

		output.event = spec.event or nil
		output.cmd = spec.cmd or nil
		output.colorscheme = spec.colorscheme or nil
		output.ft = spec.ft or nil
		output.keys = spec.keys or nil
		output.priority = spec.priority or nil
		output.lazy = spec.lazy or true
		return output
	end

	for name, spec in pairs(preprocess) do
		processed[#processed + 1] = create_spec(spec, name)
	end

	return processed
end
function M.pre_setup()
	MyVim.events.init_lazy_file()
	require("my.options")
end

return M


local lsp = vim.g.lazyvim_python_lsp or "pyright"
local ruff = vim.g.lazyvim_python_ruff or "ruff"

vim.g.snacks_animate = false


-- function M.dial(increment, g)
-- 	local mode = vim.fn.mode(true)
-- 	-- Use visual commands for VISUAL 'v', VISUAL LINE 'V' and VISUAL BLOCK '\22'
-- 	local is_visual = mode == "v" or mode == "V" or mode == "\22"
-- 	local func = (increment and "inc" or "dec") .. (g and "_g" or "_") .. (is_visual and "visual" or "normal")
-- 	local group = vim.g.dials_by_ft[vim.bo.filetype] or "default"
-- 	return require("dial.map")[func](group)
-- end

vim.g.lazyvim_picker = "snacks"
local function term_nav(dir)
	---@param self snacks.terminal
	return function(self)
		return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
			vim.cmd.wincmd(dir)
		end)
	end
end

local function get_args(config)
	local args = type(config.args) == "function" and (config.args() or {}) or config.args or {} --[[@as string[] | string ]]
	local args_str = type(args) == "table" and table.concat(args, " ") or args --[[@as string]]

	config = vim.deepcopy(config)
	---@cast args string[]
	config.args = function()
		local new_args = vim.fn.expand(vim.fn.input("Run with args: ", args_str)) --[[@as string]]
		if config.type and config.type == "java" then
			---@diagnostic disable-next-line: return-type-mismatch
			return new_args
		end
		return require("dap.utils").splitstr(new_args)
	end
	return config
end

local picker = {
	name = "snacks",
	commands = {
		files = "files",
		live_grep = "grep",
		oldfiles = "recent",
	},

	---@param source string
	---@param opts? snacks.picker.Config
	open = function(source, opts)
		return require("snacks").picker.pick(source, opts)
	end,
}


return {
	-- {
	--   "nvim-dap",
	--   dependencies = {
	--     -- virtual text for the debugger
	--     {
	--       "nvim-dap-virtual-text",
	--       opts = {},
	--     },
	--   }, -- from spec 2 -- from spec 3,
	--   keys = {
	--     {
	--       "<leader>dB",
	--       function()
	--         require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
	--       end,
	--       desc = "Breakpoint Condition",
	--     },
	--     {
	--       "<leader>db",
	--       function()
	--         require("dap").toggle_breakpoint()
	--       end,
	--       desc = "Toggle Breakpoint",
	--     },
	--     {
	--       "<leader>dc",
	--       function()
	--         require("dap").continue()
	--       end,
	--       desc = "Continue",
	--     },
	--     {
	--       "<leader>da",
	--       function()
	--         require("dap").continue({ before = get_args })
	--       end,
	--       desc = "Run with Args",
	--     },
	--     {
	--       "<leader>dC",
	--       function()
	--         require("dap").run_to_cursor()
	--       end,
	--       desc = "Run to Cursor",
	--     },
	--     {
	--       "<leader>dg",
	--       function()
	--         require("dap").goto_()
	--       end,
	--       desc = "Go to Line (No Execute)",
	--     },
	--     {
	--       "<leader>di",
	--       function()
	--         require("dap").step_into()
	--       end,
	--       desc = "Step Into",
	--     },
	--     {
	--       "<leader>dj",
	--       function()
	--         require("dap").down()
	--       end,
	--       desc = "Down",
	--     },
	--     {
	--       "<leader>dk",
	--       function()
	--         require("dap").up()
	--       end,
	--       desc = "Up",
	--     },
	--     {
	--       "<leader>dl",
	--       function()
	--         require("dap").run_last()
	--       end,
	--       desc = "Run Last",
	--     },
	--     {
	--       "<leader>do",
	--       function()
	--         require("dap").step_out()
	--       end,
	--       desc = "Step Out",
	--     },
	--     {
	--       "<leader>dO",
	--       function()
	--         require("dap").step_over()
	--       end,
	--       desc = "Step Over",
	--     },
	--     {
	--       "<leader>dP",
	--       function()
	--         require("dap").pause()
	--       end,
	--       desc = "Pause",
	--     },
	--     {
	--       "<leader>dr",
	--       function()
	--         require("dap").repl.toggle()
	--       end,
	--       desc = "Toggle REPL",
	--     },
	--     {
	--       "<leader>ds",
	--       function()
	--         require("dap").session()
	--       end,
	--       desc = "Session",
	--     },
	--     {
	--       "<leader>dt",
	--       function()
	--         require("dap").terminate()
	--       end,
	--       desc = "Terminate",
	--     },
	--     {
	--       "<leader>dw",
	--       function()
	--         require("dap.ui.widgets").hover()
	--       end,
	--       desc = "Widgets",
	--     },
	--   },
	--   after = function()
	--     vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
	--
	--     for name, sign in pairs(LazyVim.config.icons.dap) do
	--       sign = type(sign) == "table" and sign or { sign }
	--       vim.fn.sign_define(
	--         "Dap" .. name,
	--         { text = sign[1], texthl = sign[2] or "DiagnosticInfo", linehl = sign[3], numhl = sign[3] }
	--       )
	--     end
	--
	--     -- setup dap config by VsCode launch.json file
	--     local vscode = require("dap.ext.vscode")
	--     local json = require("plenary.json")
	--     vscode.json_decode = function(str)
	--       return vim.json.decode(json.json_strip_comments(str))
	--     end
	--   end,
	-- },
	-- {
	--   "nvim-dap-ui",
	--   dependencies = { "nvim-nio" },
	--   keys = {
	--     {
	--       "<leader>du",
	--       function()
	--         require("dapui").toggle({})
	--       end,
	--       desc = "Dap UI",
	--     },
	--     {
	--       "<leader>de",
	--       function()
	--         require("dapui").eval()
	--       end,
	--       desc = "Eval",
	--       mode = { "n", "v" },
	--     },
	--   },
	--   after = function()
	--     local opts = {}
	--     --PREVIOUS CONFIG
	--     local dap = require("dap")
	--     local dapui = require("dapui")
	--     dapui.setup(opts)
	--     dap.listeners.after.event_initialized["dapui_config"] = function()
	--       dapui.open({})
	--     end
	--     dap.listeners.before.event_terminated["dapui_config"] = function()
	--       dapui.close({})
	--     end
	--     dap.listeners.before.event_exited["dapui_config"] = function()
	--       dapui.close({})
	--     end
	--   end,
	-- },

	-- {
	--   "vim-illuminate",
	--
	--   after = function()
	--     local opts = {
	--       delay = 200,
	--       large_file_cutoff = 2000,
	--       large_file_overrides = {
	--         providers = { "lsp" },
	--       },
	--     }
	--     --PREVIOUS CONFIG
	--     require("illuminate").configure(opts)
	--
	--     require("snacks")
	--       .toggle({
	--         name = "Illuminate",
	--         get = function()
	--           return not require("illuminate.engine").is_paused()
	--         end,
	--         set = function(enabled)
	--           local m = require("illuminate")
	--           if enabled then
	--             m.resume()
	--           else
	--             m.pause()
	--           end
	--         end,
	--       })
	--       :map("<leader>ux")
	--
	--     local function map(key, dir, buffer)
	--       vim.keymap.set("n", key, function()
	--         require("illuminate")["goto_" .. dir .. "_reference"](false)
	--       end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
	--     end
	--
	--     map("]]", "next")
	--     map("[[", "prev")
	--
	--     -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
	--     vim.api.nvim_create_autocmd("FileType", {
	--       callback = function()
	--         local buffer = vim.api.nvim_get_current_buf()
	--         map("]]", "next", buffer)
	--         map("[[", "prev", buffer)
	--       end,
	--     })
	--   end,
	-- },
	-- TODO: Fix at full migration
	-- {
	--   "nvim-navic",
	--   lazy = true,
	--   beforeAll = function()
	--     vim.g.navic_silence = true
	--     LazyVim.lsp.on_attach(function(client, buffer)
	--       if client.supports_method("textDocument/documentSymbol") then
	--         require("nvim-navic").attach(client, buffer)
	--       end
	--     end)
	--   end,
	-- },

	
	-- {
	--   "refactoring.nvim",
	--   event = { "BufReadPre", "BufNewFile" },
	--   dependencies = {
	--     "plenary.nvim",
	--     "nvim-treesitter",
	--   },
	--   keys = {
	--     { "<leader>r", "", desc = "+refactor", mode = { "n", "v" } },
	--     {
	--       "<leader>rs",
	--       pick,
	--       mode = "v",
	--       desc = "Refactor",
	--     },
	--     {
	--       "<leader>ri",
	--       function()
	--         require("refactoring").refactor("Inline Variable")
	--       end,
	--       mode = { "n", "v" },
	--       desc = "Inline Variable",
	--     },
	--     {
	--       "<leader>rb",
	--       function()
	--         require("refactoring").refactor("Extract Block")
	--       end,
	--       desc = "Extract Block",
	--     },
	--     {
	--       "<leader>rf",
	--       function()
	--         require("refactoring").refactor("Extract Block To File")
	--       end,
	--       desc = "Extract Block To File",
	--     },
	--     {
	--       "<leader>rP",
	--       function()
	--         require("refactoring").debug.printf({ below = false })
	--       end,
	--       desc = "Debug Print",
	--     },
	--     {
	--       "<leader>rp",
	--       function()
	--         require("refactoring").debug.print_var({ normal = true })
	--       end,
	--       desc = "Debug Print Variable",
	--     },
	--     {
	--       "<leader>rc",
	--       function()
	--         require("refactoring").debug.cleanup({})
	--       end,
	--       desc = "Debug Cleanup",
	--     },
	--     {
	--       "<leader>rf",
	--       function()
	--         require("refactoring").refactor("Extract Function")
	--       end,
	--       mode = "v",
	--       desc = "Extract Function",
	--     },
	--     {
	--       "<leader>rF",
	--       function()
	--         require("refactoring").refactor("Extract Function To File")
	--       end,
	--       mode = "v",
	--       desc = "Extract Function To File",
	--     },
	--     {
	--       "<leader>rx",
	--       function()
	--         require("refactoring").refactor("Extract Variable")
	--       end,
	--       mode = "v",
	--       desc = "Extract Variable",
	--     },
	--     {
	--       "<leader>rp",
	--       function()
	--         require("refactoring").debug.print_var()
	--       end,
	--       mode = "v",
	--       desc = "Debug Print Variable",
	--     },
	--   },
	--   after = function()
	--     local opts = {
	--       prompt_func_return_type = {
	--         go = false,
	--         java = false,
	--         cpp = false,
	--         c = false,
	--         h = false,
	--         hpp = false,
	--         cxx = false,
	--       },
	--       prompt_func_param_type = {
	--         go = false,
	--         java = false,
	--         cpp = false,
	--         c = false,
	--         h = false,
	--         hpp = false,
	--         cxx = false,
	--       },
	--       printf_statements = {},
	--       print_var_statements = {},
	--       show_success_message = true, -- shows a message with information about the refactor on success
	--       -- i.e. [Refactor] Inlined 3 variable occurrences
	--     }
	--     --PREVIOUS CONFIG
	--     require("refactoring").setup(opts)
	--     if LazyVim.has("telescope.nvim") then
	--       LazyVim.on_load("telescope.nvim", function()
	--         require("telescope").load_extension("refactoring")
	--       end)
	--     end
	--   end,
	-- },
	-- {
	-- 	"clangd_extensions.nvim",
	-- 	lazy = true,
	-- 	config = function() end,
	-- },
	-- {
	-- 	"SchemaStore.nvim",
	-- 	lazy = true,
	-- },
	
	-- {
	-- 	"persistence.nvim",
	-- 	event = "BufReadPre",
	-- 	after = function()
	-- 		local opts = {}
	-- 	end,
	-- },
	
}

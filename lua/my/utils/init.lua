---@class my.util
---@field format my.util.format
---@field lsp my.util.lsp
local M = {}
setmetatable(M, {
  __index = function (t,k)
    t[k] = require("my.utils." .. k)
    return t[k]
  end
})

---@return boolean
function M.is_win()
  return false
end

local defer_augroup = vim.api.nvim_create_augroup("deferred", {clear = true})

---@param func function
---@param fast boolean?
---@return nil
function M.load_at_startup(func, fast)
  vim.api.nvim_create_autocmd("User", {
    pattern = fast and "DeferredUIEnter" or "Lazyfile",
    group = defer_augroup,
    callback = func
  })
end


function M.defer(func)
  vim.schedule(func)
end



-- function M.safe_map()
--   opts = vim.tbl_extend("force", { silent = true }, opts or {})
--   vim.keymap.set(mode, lhs, rhs, opts)
-- end

-- -@param opts? {level?: number}
-- function M.pretty_trace(opts)
--   opts = opts or {}
--   -- local Config = require("lazy.core.config")
--   local trace = {}
--   local level = opts.level or 2
--   while true do
--     local info = debug.getinfo(level, "Sln")
--     if not info then
--       break
--     end
--     if info.what ~= "C" and (Config.options.debug or not info.source:find("lazy.nvim")) then
--       local source = info.source:sub(2)
--       if source:find(Config.options.root, 1, true) == 1 then
--         source = source:sub(#Config.options.root + 1)
--       end
--       source = vim.fn.fnamemodify(source, ":p:~:.") --[[@as string]]
--       local line = "  - " .. source .. ":" .. info.currentline
--       if info.name then
--         line = line .. " _in_ **" .. info.name .. "**"
--       end
--       table.insert(trace, line)
--     end
--     level = level + 1
--   end
--   return #trace > 0 and ("\n\n# stacktrace:\n" .. table.concat(trace, "\n")) or ""
-- end

---@param fn fun(...)
---@param opts? {msg?: string,on_error?:fun(msg:string,...):any}
function M.try(fn, opts)
  opts = type(opts) == "string" and { msg = opts } or opts or {}
  local msg = opts.msg
  local error_handler = function(err)
    msg = (msg and (msg .. "\n\n") or "") .. err --.. M.pretty_trace()
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

---@param msg string
---@param opts? table
---@return nil
function M.error(msg, opts)
  opts = opts or {}
  opts.level = vim.log.levels.ERROR
  M.notify(msg, opts)
end

---@param msg string
---@param opts? table
---@return nil
function M.warn(msg, opts)
  opts = opts or {}
  opts.level = vim.log.levels.WARN
  M.notify(msg, opts)
end

---@param msg string
---@param opts? table
---@return nil
function M.notify(msg, opts)
  vim.notfiy(msg, (opts and opts.level) or vim.log.levels.INFO)
end


function M.pairs(opts)
  require("snacks").toggle({
    name = "Mini Pairs",
    get = function()
      return not vim.g.minipairs_disable
    end,
    set = function(state)
      vim.g.minipairs_disable = not state
    end,
  }):map("<leader>up")

  local pairs = require("mini.pairs")
  pairs.setup(opts)
  local open = pairs.open
  pairs.open = function(pair, neigh_pattern)
    if vim.fn.getcmdline() ~= "" then
      return open(pair, neigh_pattern)
    end
    local o, c = pair:sub(1, 1), pair:sub(2, 2)
    local line = vim.api.nvim_get_current_line()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local next = line:sub(cursor[2] + 1, cursor[2] + 1)
    local before = line:sub(1, cursor[2])
    if opts.markdown and o == "`" and vim.bo.filetype == "markdown" and before:match("^%s*``") then
      return "`\n```" .. vim.api.nvim_replace_termcodes("<up>", true, true, true)
    end
    if opts.skip_next and next ~= "" and next:match(opts.skip_next) then
      return o
    end
    if opts.skip_ts and #opts.skip_ts > 0 then
      local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1, math.max(cursor[2] - 1, 0))
      for _, capture in ipairs(ok and captures or {}) do
        if vim.tbl_contains(opts.skip_ts, capture.capture) then
          return o
        end
      end
    end
    if opts.skip_unbalanced and next == c and c ~= o then
      local _, count_open = line:gsub(vim.pesc(pair:sub(1, 1)), "")
      local _, count_close = line:gsub(vim.pesc(pair:sub(2, 2)), "")
      if count_close > count_open then
        return o
      end
    end
    return open(pair, neigh_pattern)
  end
end

---@param ai_type string
---@return {from:{line:number,col:number},to:{line:number,col:number}}
function M.ai_buffer(ai_type)
  local start_line, end_line = 1, vim.fn.line("$")
  if ai_type == "i" then
    -- Skip first and last blank lines for `i` textobject
    local first_nonblank, last_nonblank = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
    -- Do nothing for buffer with all blanks
    if first_nonblank == 0 or last_nonblank == 0 then
      return { from = { line = start_line, col = 1 } }
    end
    start_line, end_line = first_nonblank, last_nonblank
  end

  local to_col = math.max(vim.fn.getline(end_line):len(), 1)
  return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
end

-- register all text objects with which-key
---@param opts table
function M.ai_whichkey(opts)
  local objects = {
    { " ", desc = "whitespace" },
    { '"', desc = '" string' },
    { "'", desc = "' string" },
    { "(", desc = "() block" },
    { ")", desc = "() block with ws" },
    { "<", desc = "<> block" },
    { ">", desc = "<> block with ws" },
    { "?", desc = "user prompt" },
    { "U", desc = "use/call without dot" },
    { "[", desc = "[] block" },
    { "]", desc = "[] block with ws" },
    { "_", desc = "underscore" },
    { "`", desc = "` string" },
    { "a", desc = "argument" },
    { "b", desc = ")]} block" },
    { "c", desc = "class" },
    { "d", desc = "digit(s)" },
    { "e", desc = "CamelCase / snake_case" },
    { "f", desc = "function" },
    { "g", desc = "entire file" },
    { "i", desc = "indent" },
    { "o", desc = "block, conditional, loop" },
    { "q", desc = "quote `\"'" },
    { "t", desc = "tag" },
    { "u", desc = "use/call" },
    { "{", desc = "{} block" },
    { "}", desc = "{} with ws" },
  }

  ---@type wk.Spec[]
  local ret = { mode = { "o", "x" } }
  ---@type table<string, string>
  local mappings = vim.tbl_extend("force", {}, {
    around = "a",
    inside = "i",
    around_next = "an",
    inside_next = "in",
    around_last = "al",
    inside_last = "il",
  }, opts.mappings or {})
  mappings.goto_left = nil
  mappings.goto_right = nil

  for name, prefix in pairs(mappings) do
    name = name:gsub("^around_", ""):gsub("^inside_", "")
    ret[#ret + 1] = { prefix, group = name }
    for _, obj in ipairs(objects) do
      local desc = obj.desc
      if prefix:sub(1, 1) == "i" then
        desc = desc:gsub(" with ws", "")
      end
      ret[#ret + 1] = { prefix .. obj[1], desc = obj.desc }
    end
  end
  require("which-key").add(ret, { notify = false })
end

-- Lua line stuff

-- -@param name string
-- -@param icon? string
-- function M.cmp_source(name, icon)
--   icon = icon or LazyVim.config.icons.kinds[name:sub(1, 1):upper() .. name:sub(2)]
--   local started = false
--   return M.status(icon, function()
--     if not package.loaded["cmp"] then
--       return
--     end
--     for _, s in ipairs(require("cmp").core.sources or {}) do
--       if s.name == name then
--         if s.source:is_available() then
--           started = true
--         else
--           return started and "error" or nil
--         end
--         if s.status == s.SourceStatus.FETCHING then
--           return "pending"
--         end
--         return "ok"
--       end
--     end
--   end)
-- end

-- Stuff I may want later
---@param opts? {relative: "cwd"|"root", modified_hl: string?, directory_hl: string?, filename_hl: string?, modified_sign: string?, readonly_icon: string?, length: number?}
function M.pretty_path(opts)
  opts = vim.tbl_extend("force", {
    relative = "cwd",
    modified_hl = "MatchParen",
    directory_hl = "",
    filename_hl = "Bold",
    modified_sign = "",
    readonly_icon = " 󰌾 ",
    length = 3,
  }, opts or {})

  return function(self)
    local path = vim.fn.expand("%:p") --[[@as string]]

    if path == "" then
      return ""
    end

    path = LazyVim.norm(path)
    local root = LazyVim.root.get({ normalize = true })
    local cwd = LazyVim.root.cwd()

    if opts.relative == "cwd" and path:find(cwd, 1, true) == 1 then
      path = path:sub(#cwd + 2)
    elseif path:find(root, 1, true) == 1 then
      path = path:sub(#root + 2)
    end

    local sep = package.config:sub(1, 1)
    local parts = vim.split(path, "[\\/]")

    if opts.length == 0 then
      parts = parts
    elseif #parts > opts.length then
      parts = { parts[1], "…", unpack(parts, #parts - opts.length + 2, #parts) }
    end

    if opts.modified_hl and vim.bo.modified then
      parts[#parts] = parts[#parts] .. opts.modified_sign
      parts[#parts] = M.format(self, parts[#parts], opts.modified_hl)
    else
      parts[#parts] = M.format(self, parts[#parts], opts.filename_hl)
    end

    local dir = ""
    if #parts > 1 then
      dir = table.concat({ unpack(parts, 1, #parts - 1) }, sep)
      dir = M.format(self, dir .. sep, opts.directory_hl)
    end

    local readonly = ""
    if vim.bo.readonly then
      readonly = M.format(self, opts.readonly_icon, opts.modified_hl)
    end
    return dir .. parts[#parts] .. readonly
  end
end

function M.root_dir(opts)
  opts = vim.tbl_extend("force", {
    cwd = false,
    subdirectory = true,
    parent = true,
    other = true,
    icon = "󱉭 ",
    color = function()
      return { fg = Snacks.util.color("Special") }
    end,
  }, opts or {})

  local function get()
    local cwd = LazyVim.root.cwd()
    local root = LazyVim.root.get({ normalize = true })
    local name = vim.fs.basename(root)

    if root == cwd then
      -- root is cwd
      return opts.cwd and name
    elseif root:find(cwd, 1, true) == 1 then
      -- root is subdirectory of cwd
      return opts.subdirectory and name
    elseif cwd:find(root, 1, true) == 1 then
      -- root is parent directory of cwd
      return opts.parent and name
    else
      -- root and cwd are not related
      return opts.other and name
    end
  end

  return {
    function()
      return (opts.icon and opts.icon .. " ") .. get()
    end,
    cond = function()
      return type(get()) == "string"
    end,
    color = opts.color,
  }
end

-- optimized treesitter foldexpr for Neovim >= 0.10.0
function M.foldexpr()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].ts_folds == nil then
    -- as long as we don't have a filetype, don't bother
    -- checking if treesitter is available (it won't)
    if vim.bo[buf].filetype == "" then
      return "0"
    end
    if vim.bo[buf].filetype:find("dashboard") then
      vim.b[buf].ts_folds = false
    else
      vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
    end
  end
  return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or "0"
end


M.lazy_defaults = {
	-- colorscheme can be a string like `catppuccin` or a function that will load the colorscheme

	-- load the default settings
	defaults = {
		autocmds = true, -- lazyvim.config.autocmds
		keymaps = true, -- lazyvim.config.keymaps
		-- lazyvim.config.options can't be configured here since that's loaded before lazyvim setup
		-- if you want to disable loading options, add `package.loaded["lazyvim.config.options"] = true` to the top of your init.lua
	},
	news = {
		-- When enabled, NEWS.md will be shown when changed.
		-- This only contains big new features and breaking changes.
		lazyvim = true,
		-- Same but for Neovim's news.txt
		neovim = false,
	},
  -- icons used by other plugins
  -- stylua: ignore

  icons = {
    misc = {
      dots = "󰇘",
    },
    ft = {
      octo = "",
    },
    dap = {
      Stopped             = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
      Breakpoint          = " ",
      BreakpointCondition = " ",
      BreakpointRejected  = { " ", "DiagnosticError" },
      LogPoint            = ".>",
    },
    diagnostics = {
      Error = " ",
      Warn  = " ",
      Hint  = " ",
      Info  = " ",
    },
    git = {
      added    = " ",
      modified = " ",
      removed  = " ",
    },
    kinds = {
      Array         = " ",
      Boolean       = "󰨙 ",
      Class         = " ",
      Codeium       = "󰘦 ",
      Color         = " ",
      Control       = " ",
      Collapsed     = " ",
      Constant      = "󰏿 ",
      Constructor   = " ",
      Copilot       = " ",
      Enum          = " ",
      EnumMember    = " ",
      Event         = " ",
      Field         = " ",
      File          = " ",
      Folder        = " ",
      Function      = "󰊕 ",
      Interface     = " ",
      Key           = " ",
      Keyword       = " ",
      Method        = "󰊕 ",
      Module        = " ",
      Namespace     = "󰦮 ",
      Null          = " ",
      Number        = "󰎠 ",
      Object        = " ",
      Operator      = " ",
      Package       = " ",
      Property      = " ",
      Reference     = " ",
      Snippet       = "󱄽 ",
      String        = " ",
      Struct        = "󰆼 ",
      Supermaven    = " ",
      TabNine       = "󰏚 ",
      Text          = " ",
      TypeParameter = " ",
      Unit          = " ",
      Value         = " ",
      Variable      = "󰀫 ",
    },
  },
	---@type table<string, string[]|boolean>?
	kind_filter = {
		default = {
			"Class",
			"Constructor",
			"Enum",
			"Field",
			"Function",
			"Interface",
			"Method",
			"Module",
			"Namespace",
			"Package",
			"Property",
			"Struct",
			"Trait",
		},
		markdown = false,
		help = false,
		-- you can specify a different filter for each filetype
		lua = {
			"Class",
			"Constructor",
			"Enum",
			"Field",
			"Function",
			"Interface",
			"Method",
			"Module",
			"Namespace",
			-- "Package", -- remove package since luals uses it for control flow structures
			"Property",
			"Struct",
			"Trait",
		},
	},
}

---TODO: This is very lazy (pun intended.) Please organize better


--- Get highlight properties for a given highlight name
--- @param name string The highlight group name
--- @param fallback? table The fallback highlight properties
--- @return table properties # the highlight group properties
function M.get_hlgroup(name, fallback)
  if vim.fn.hlexists(name) == 1 then
    local group = vim.api.nvim_get_hl(0, { name = name })

    local hl = {
      fg = group.fg == nil and "NONE" or M.parse_hex(group.fg),
      bg = group.bg == nil and "NONE" or M.parse_hex(group.bg),
    }

    return hl
  end
  return fallback or {}
end

--- Remove a buffer by its number without affecting window layout
--- @param buf? number The buffer number to delete
function M.delete_buffer(buf)
  if buf == nil or buf == 0 then
    buf = vim.api.nvim_get_current_buf()
  end

  vim.api.nvim_command("bwipeout " .. buf)
end

--- Switch to the previous buffer
function M.switch_to_previous_buffer()
  local ok, _ = pcall(function()
    vim.cmd("buffer #")
  end)
  if not ok then
    vim.notify("No other buffer to switch to!", 3, { title = "Warning" })
  end
end

--- Get the number of open buffers
--- @return number
function M.get_buffer_count()
  local count = 0
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fn.bufname(buf) ~= "" then
      count = count + 1
    end
  end
  return count
end

--- Parse a given integer color to a hex value.
--- @param int_color number
function M.parse_hex(int_color)
  return string.format("#%x", int_color)
end

--- Create a centered floating window of a given width and height, relative to the size of the screen.
--- @param width number width of the window where 1 is 100% of the screen
--- @param height number height of the window - between 0 and 1
--- @param buf number The buffer number
--- @return number The window number
function M.open_centered_float(width, height, buf)
  buf = buf or vim.api.nvim_create_buf(false, true)
  local win_width = math.floor(vim.o.columns * width)
  local win_height = math.floor(vim.o.lines * height)
  local offset_y = math.floor((vim.o.lines - win_height) / 2)
  local offset_x = math.floor((vim.o.columns - win_width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = win_width,
    height = win_height,
    row = offset_y,
    col = offset_x,
    style = "minimal",
    border = "single",
  })

  return win
end

--- Open the help window in a floating window
--- @param buf number The buffer number
function M.open_help(buf)
  if buf ~= nil and vim.bo[buf].filetype == "help" then
    local help_win = vim.api.nvim_get_current_win()
    local new_win = M.open_centered_float(0.6, 0.7, buf)

    -- set keymap 'q' to close the help window
    vim.api.nvim_buf_set_keymap(buf, "n", "q", ":q!<CR>", {
      nowait = true,
      noremap = true,
      silent = true,
    })

    -- set scroll position
    vim.wo[help_win].scroll = vim.wo[new_win].scroll

    -- close the help window
    vim.api.nvim_win_close(help_win, true)
  end
end

--- Run a shell command and return the output
--- @param cmd table The command to run in the format { "command", "arg1", "arg2", ... }
--- @param cwd? string The current working directory
--- @return table stdout, number? return_code, table? stderr
function M.get_cmd_output(cmd, cwd)
  if type(cmd) ~= "table" then
    vim.notify("Command must be a table", 3, { title = "Error" })
    return {}
  end

  local command = table.remove(cmd, 1)
  local stderr = {}
  local stdout, ret = require("plenary.job")
    :new({
      command = command,
      args = cmd,
      cwd = cwd,
      on_stderr = function(_, data)
        table.insert(stderr, data)
      end,
    })
    :sync()

  return stdout, ret, stderr
end

--- Write a table of lines to a file
--- @param file string Path to the file
--- @param lines table Table of lines to write to the file
function M.write_to_file(file, lines)
  if not lines or #lines == 0 then
    return
  end
  local buf = io.open(file, "w")
  for _, line in ipairs(lines) do
    if buf ~= nil then
      buf:write(line .. "\n")
    end
  end

  if buf ~= nil then
    buf:close()
  end
end

--- Display a diff between the current buffer and a given file
--- @param file string The file to diff against the current buffer
function M.diff_file(file)
  local pos = vim.fn.getpos(".")
  local current_file = vim.fn.expand("%:p")
  vim.cmd("edit " .. file)
  vim.cmd("vert diffsplit " .. current_file)
  vim.fn.setpos(".", pos)
end

--- Display a diff between a file at a given commit and the current buffer
--- @param commit string The commit hash
--- @param file_path string The file path
function M.diff_file_from_history(commit, file_path)
  local extension = vim.fn.fnamemodify(file_path, ":e") == "" and "" or "." .. vim.fn.fnamemodify(file_path, ":e")
  local temp_file_path = os.tmpname() .. extension

  local cmd = { "git", "show", commit .. ":" .. file_path }
  local out = M.get_cmd_output(cmd)

  M.write_to_file(temp_file_path, out)
  M.diff_file(temp_file_path)
end

--- Open a telescope picker to select a file to diff against the current buffer
--- @param recent? boolean If true, open the recent files picker
function M.telescope_diff_file(recent)
  local picker = require("telescope.builtin").find_files
  if recent then
    picker = require("telescope.builtin").oldfiles
  end

  picker({
    prompt_title = "Select File to Compare",
    attach_mappings = function(prompt_bufnr)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        M.diff_file(selection.value)
      end)
      return true
    end,
  })
end

--- Open a telescope picker to select a commit to diff against the current buffer
function M.telescope_diff_from_history()
  local current_file = vim.fn.fnamemodify(vim.fn.expand("%:p"), ":~:."):gsub("\\", "/")
  require("telescope.builtin").git_commits({
    git_command = { "git", "log", "--pretty=oneline", "--abbrev-commit", "--follow", "--", current_file },
    attach_mappings = function(prompt_bufnr)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        M.diff_file_from_history(selection.value, current_file)
      end)
      return true
    end,
  })
end

return M

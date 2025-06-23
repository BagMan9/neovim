-- TODO: Allow for in-existing-expression creation
-- Create loading indicator
-- Ensure error tolerance
-- Make easier support for revs (see in-existing-expression)

---@class MyVim.fetcher
local M = setmetatable({}, {
	__call = function(m, ...)
		return m.getSHA(...)
	end,
})

local base_query = [[(apply_expression
  function: (select_expression
    attrpath: (attrpath) @fetcher )
  (#match? @fetcher "%s")
  argument: (attrset_expression (binding_set 
        binding: (binding expression: (string_expression (string_fragment) @owner)) 
        binding: (binding expression: (string_expression (string_fragment) @repo))
          ))
  (#eq? @owner "%s")
  (#eq? @repo "%s")
  ) @fetch_expr]]

local nio = require("nio")

---@param url string
---@return {stub:string[],fetcher:string,owner:string,repo:string}
local function create_fetch_stub(url)
	local prejson = nio.process.run({ cmd = "nurl", args = { "-p", url } })
	local output = prejson and prejson.stdout.read() or "Error"
	local parsed = vim.json.decode(output)
	local stub_strings = {
		"pkgs." .. parsed.fetcher .. " {",
		'   owner = "' .. parsed.args.owner .. '";',
		'   repo = "' .. parsed.args.repo .. '";',
		"};",
	}
	local out = {
		stub = stub_strings,
		fetcher = parsed.fetcher,
		owner = parsed.args.owner,
		repo = parsed.args.repo,
	}
	return out
end

---@param url string
---@return string[]
local function full_fetch(url)
	local lines = {}
	local fetch_proc = nio.process.run({ cmd = "nurl", args = { url } })
	local full_txt = fetch_proc and fetch_proc.stdout.read() or ""
	full_txt = "pkgs." .. full_txt
	for s in full_txt:gmatch("[^\r\n]+") do
		table.insert(lines, s)
	end
	return lines
end

function M.getSHA()
	nio.run(function()
		---@diagnostic disable-next-line
		local url = nio.ui.input({ prompt = "Enter URL: " })
		if not url then
			return
		end
		local fetch_data = create_fetch_stub(url)
		nio.api.nvim_put(fetch_data.stub, "", true, false)

		local full = full_fetch(url)
		local query_str = string.format(base_query, fetch_data.fetcher, fetch_data.owner, fetch_data.repo)

		return query_str, full
	end, function(success, s_expr, txt)
		if not success then
			return
		end
		nio.scheduler()
		local query = vim.treesitter.query.parse("nix", s_expr)
		local buf_tree = vim.treesitter.get_parser():parse()[1]
		for id, node, _, _ in query:iter_captures(buf_tree:root(), 0) do
			local name = query.captures[id]
			if name == "fetch_expr" then
				print(name)
				local srow, scol, erow, ecol = node:range()
				nio.api.nvim_buf_set_text(0, srow, scol, erow, ecol, txt)
			end
		end
	end)
end

return M

-- TODO: You're probably pretty close with this:
-- Then setup REST client (kulala)
-- Also octo-nvim & neogen
-- Then maybe give secret management some thought again
-- And get your mind back into netbox:
-- SQL Database probably makes this easy
-- Location's unique ID in netbox is a combination of all of their parents Ids?
-- How does one properly cross reference a given device and figure out where it belongs in the graph?

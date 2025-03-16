local finder = require("clapi.finder")
local ts = require("clapi.treesitter")
local parsers = require("nvim-treesitter.parsers")

local bufnr = 12
--
-- Load the treesitter parser for the language
local treesitter_filetype = parsers.get_buf_lang(bufnr)
local parser = vim.treesitter.get_parser(bufnr, treesitter_filetype)
if not parser then
	error("No parser for the current buffer")
	return
end

-- local query_str = ts.get_full_query("php")
-- Parse the query
--
local query = vim.treesitter.query.parse(
	"php",
	[[
		(class_declaration
		  (base_clause 
			(name) @parent))
	]]
)
if not query then
	error("Failed to parse the uery")
	return {}
end

-- Parse the content
-- TODO: nil check
local tree = parser:parse()
if not tree then
	error("Failed to parse the buffer content")
	return
end

tree = tree[1]

local root = tree:root()

for id, node, metadata in query:iter_captures(root, bufnr) do
	local capture_name = query.captures[id]
	local line, char = node:start()
	vim.print(capture_name, line, char)
end
-- ts.parse_file({ bufnr = 5 })
-- finder.builtin({ bufnr = 7 })

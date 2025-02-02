local function print_node(node)
	local start_row, start_col, end_row, end_col = node:range()
	print(string.format("Node type: %s, Range: (%d,%d)-(%d,%d)", node:type(), start_row, start_col, end_row, end_col))
end

---@param node TSNode
---@param source string|integer
---@param opts table|nil
local get_node_text = function(node, source, opts)
	return vim.treesitter.get_node_text(node, source, opts)
end

---@param buffer integer
---@param query vim.treesitter.Query
local prueba = function(query, buffer)
	local parser = vim.treesitter.get_parser(buffer)
	local tree = parser:parse()[1]
	local root = tree:root()

	-- Execute the query
	for id, node, _ in query:iter_captures(root, 0) do
		local capture_name = query.captures[id]
		local function_name = get_node_text(node, buffer)
		-- local v = node:child(1)
		print(capture_name, function_name)
	end
end

local query_php = vim.treesitter.query.parse(
	"php",
	[[
	 (method_declaration
            (visibility_modifier)
            name: (name) @method_name
        )
	 (property_promotion_parameter
            visibility: (visibility_modifier) @visibility
            name: (variable_name) @prop_name
        )
	]]
)

prueba(query_php, 53)

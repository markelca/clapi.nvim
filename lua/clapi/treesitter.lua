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
local main = function(query, buffer)
	local parser = vim.treesitter.get_parser(buffer)
	local tree = parser:parse()[1]
	local root = tree:root()

	for pattern, match, _ in query:iter_matches(root, buffer) do
		local type = nil
		local visibility = nil
		local name = nil
		local result = { name = nil, type = nil, visibility = nil }
		for id, node in pairs(match) do
			local capture_name = query.captures[id]
			local text = vim.treesitter.get_node_text(node, buffer)
			-- print(capture_name, text)

			if capture_name == "method_name" then
				type = "function"
				name = text
			elseif capture_name == "prop_name" then
				type = "property"
				name = text
			elseif capture_name == "visibility" then
				visibility = text
			end
		end
		print(type .. " " .. name .. " " .. visibility)
	end
end

local query = vim.treesitter.query.parse(
	"php",
	[[
	 (method_declaration
            (visibility_modifier) @visibility
            name: (name) @method_name
        )
	 (property_promotion_parameter
            visibility: (visibility_modifier) @visibility
            name: (variable_name) @prop_name
        )
	]]
)

main(query, 9)

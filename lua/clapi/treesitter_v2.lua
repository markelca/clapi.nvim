-- Define your query
-- Define your query
local query = vim.treesitter.query.parse(
	"php",
	[[
(method_declaration
  (visibility_modifier) @_visibility
  name: (name) @definition
  (#set! definition.kind "method")
  (#set! definition.visibility @_visibility)
)

(property_promotion_parameter
  visibility: (visibility_modifier) @_visibility
  name: (variable_name) @definition
  (#set! definition.kind "property")
  (#set! definition.visibility @_visibility)
)

(property_declaration
  (visibility_modifier) @_visibility
  (property_element
    (variable_name) @definition)
  (#set! definition.kind "property")
  (#set! definition.visibility @_visibility)
)
]]
)

-- Get the buffer and language tree
local bufnr = 8
local parser = vim.treesitter.get_parser(bufnr, "php")
local tree = parser:parse()[1]
local root = tree:root()

-- Collect the results
local results = {}

for pattern, match, metadata in query:iter_matches(root, bufnr) do
	for id, node in pairs(match) do
		local capture_name = query.captures[id]

		if capture_name == "definition" then
			local name = vim.treesitter.get_node_text(node, bufnr)
			-- print(vim.print(metadata, id))
			local kind = metadata[id].kind
			local visibility = vim.treesitter.get_node_text(metadata[id].visibility, bufnr)

			-- Clean up property names (remove $ prefix)
			if kind == "property" then
				name = name:gsub("^%$", "")
			end

			table.insert(results, {
				kind = kind,
				visibility = visibility,
				name = name,
			})
		end
	end
end

-- Print the results in the desired format
print("{")
for _, item in ipairs(results) do
	print(string.format("  { kind = %s, visibility = %s, name = %s },", item.kind, item.visibility, item.name))
end
print("}")

local utils = require("telescope.utils")

local M = {}

local queries = {
	["php"] = vim.treesitter.query.parse(
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
	),
}

---@param buffer integer
local search = function(buffer)
	local filetype = vim.api.nvim_buf_get_option(buffer, "filetype")
	local lang = vim.treesitter.language.get_lang(filetype) or filetype
	if lang == "" then
		vim.notify("Error: No language detected", vim.log.levels.ERROR)
		return
	end

	if queries[lang] == nil then
		vim.notify(string.format("Error: Language not supported (%s)", lang), vim.log.levels.ERROR)
		return nil
	end

	local query = queries[lang]
	local parser = vim.treesitter.get_parser(buffer)
	local tree = parser:parse()[1]
	local root = tree:root()

	local results = {}
	for _, match, _ in query:iter_matches(root, buffer) do
		local result = { name = nil, type = nil, visibility = nil }
		for id, node in pairs(match) do
			local capture_name = query.captures[id]
			local text = vim.treesitter.get_node_text(node, buffer)

			if capture_name == "method_name" then
				result["type"] = "function"
				result["name"] = text
			elseif capture_name == "prop_name" then
				result["type"] = "property"
				result["name"] = text
			elseif capture_name == "visibility" then
				result["visibility"] = text
			end
		end
		table.insert(results, result)
	end
	return results
end

M.search = search

-- local results = search(query, 7)
-- print(vim.inspect(search(4)))
return M

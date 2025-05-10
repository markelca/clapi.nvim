local Parser = require("clapi.parser.__parser")

---@class JavaParser : Parser
local JavaParser = Parser:new()

---Extract visibility from Java modifiers
---@param node TSNode The treesitter node containing modifiers
---@param bufnr integer The buffer number of the source file
---@return string visibility The visibility modifier of the node
local function _get_visibility_from_modifiers(node, bufnr)
	local modifiers = vim.treesitter.get_node_text(node, bufnr)

	for word in string.gmatch(modifiers, "%S+") do
		local visibilities = {
			["private"] = true,
			["public"] = true,
			["protected"] = true,
		}
		if visibilities[word] then
			return word
		end
	end
	return "private"
end

---Get visibility modifier of a node
---@param node TSNode The treesitter node of the visibility modifier
---@param bufnr integer The buffer number of the source file
---@return string visibility The visibility modifier of the node
function JavaParser.get_visibility(node, bufnr)
	for n, _ in node:iter_children() do
		local type = n:type()
		if type == "modifiers" then
			return _get_visibility_from_modifiers(n, bufnr)
		end
	end
	return "private"
end

---Parse a property node
---@param node TSNode The treesitter node of the property
---@param start_col integer Starting column of the node
---@param start_row integer Starting row of the node
---@param opts table Additional options
---@return table PropertyInfo Property information
function JavaParser.parse_property(node, start_col, start_row, opts)
	local visibility = JavaParser.get_visibility(node:parent():parent(), opts.bufnr)
	local text = vim.treesitter.get_node_text(node, opts.bufnr)
	return {
		col = start_col + 1,
		filename = opts.filename,
		visibility = visibility,
		kind = "Property",
		lnum = start_row + 1,
		text = "[Property] " .. opts.class_name .. text,
	}
end

---Parse a method node
---@param node TSNode The treesitter node of the method
---@param start_col integer Starting column of the node
---@param start_row integer Starting row of the node
---@param opts table Additional options
---@return table MethodInfo Method information
function JavaParser.parse_method(node, start_col, start_row, opts)
	local visibility = JavaParser.get_visibility(node:parent(), opts.bufnr)
	local text = vim.treesitter.get_node_text(node, opts.bufnr)
	return {
		col = start_col + 1,
		filename = opts.filename,
		visibility = visibility,
		kind = "Function",
		lnum = start_row + 1,
		text = "[Function] " .. opts.class_name .. text,
	}
end

return JavaParser

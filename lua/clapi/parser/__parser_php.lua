local Parser = require("clapi.parser.__parser")

---@class PhpParser : Parser
local PhpParser = Parser:new()

---Get visibility modifier of a node
---@param node TSNode The treesitter node of the visibility modifier
---@param bufnr integer The buffer number of the source file
---@return string visibility The visibility modifier of the node
function PhpParser.get_visibility(node, bufnr)
	for n, _ in node:iter_children() do
		local type = n:type()
		if type == "visibility_modifier" then -- TODO: make this line language agnostic
			return vim.treesitter.get_node_text(n, bufnr)
		end
	end
	return "public" -- Public by default (TODO: review this wih more languages)
end

---Parse a method node
---@param node TSNode The treesitter node of the method
---@param start_col integer Starting column of the node
---@param start_row integer Starting row of the node
---@param opts table Additional options
---@return table MethodInfo Method information
function PhpParser.parse_method(node, start_col, start_row, opts)
	local visibility = PhpParser.get_visibility(node:parent(), opts.bufnr)
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

---Parse a constant node
---@param node TSNode The treesitter node of the constant
---@param start_col integer Starting column of the node
---@param start_row integer Starting row of the node
---@param opts table Additional options
---@return table ConstantInfo Constant information
function PhpParser.parse_constant(node, start_col, start_row, opts)
	local text = vim.treesitter.get_node_text(node, opts.bufnr)
	local visibility = PhpParser.get_visibility(node:parent():parent(), opts.bufnr)
	return {
		col = start_col + 1,
		filename = opts.filename,
		visibility = visibility,
		kind = "Method",
		lnum = start_row + 1,
		text = "[Constant] " .. opts.class_name .. text,
	}
end

---Parse a property node
---@param node TSNode The treesitter node of the property
---@param start_col integer Starting column of the node
---@param start_row integer Starting row of the node
---@param opts table Additional options
---@return table PropertyInfo Property information
function PhpParser.parse_property(node, start_col, start_row, opts)
	local parent = node:parent()
	local prop_parent = parent

	-- Find the parent property declaration or promotion parameter
	while
		prop_parent
		and prop_parent:type() ~= "property_declaration"
		and prop_parent:type() ~= "property_promotion_parameter"
	do
		prop_parent = prop_parent:parent()
	end

	if not prop_parent then
		error("Couldn't find the parent for the property")
		return
	end

	local visibility = PhpParser.get_visibility(prop_parent, opts.bufnr)
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

return PhpParser

local Parser = require("clapi.parsers")

local JavaParser = Parser:new()

function JavaParser.hi()
	print("Hi from java!")
end

---@param node TSNode The treesitter node of the visibility modifier
---@param bufnr integer The buffer number of the source file
---@return string|nil visibility The visibility modifier of the node
function JavaParser.get_visibility_from_modifiers(node, bufnr)
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
end

---@param node TSNode The treesitter node of the visibility modifier
---@param bufnr integer The buffer number of the source file
---@return string visibility The visibility modifier of the node
function JavaParser.get_visibility(node, bufnr)
	for n, _ in node:iter_children() do
		local type = n:type()
		if type == "modifiers" then -- TODO: make this line language agnostic
			return JavaParser.get_visibility_from_modifiers(n, bufnr)
		end
	end
	return "public" -- Public by default (TODO: review this wih more languages)
end

---@param node TSNode
---@param start_col integer
---@param start_row integer
---@param opts table
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

---@param node TSNode
---@param start_col integer
---@param start_row integer
---@param opts table
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

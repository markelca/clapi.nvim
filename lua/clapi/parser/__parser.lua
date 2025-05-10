---@class Parser
local Parser = {}

function Parser:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

---@param node TSNode The treesitter node of the visibility modifier
---@param bufnr integer The buffer number of the source file
---@return string visibility The visibility modifier of the node
function Parser.get_visibility(node, bufnr)
	error("Not implemented!")
end

---@param node TSNode
---@param start_col integer
---@param start_row integer
---@param opts table
function Parser.parse_method(node, start_col, start_row, opts)
	error("Not implemented!")
end

---@param node TSNode
---@param start_col integer
---@param start_row integer
---@param opts table
function Parser.parse_constant(node, start_col, start_row, opts)
	error("Not implemented!")
end

---@param node TSNode
---@param start_col integer
---@param start_row integer
---@param opts table
function Parser.parse_property(node, start_col, start_row, opts)
	error("Not implemented!")
end

return Parser

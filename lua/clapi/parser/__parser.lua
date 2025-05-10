---@class Parser
---@field private __index any
local Parser = {}

---Create a new parser instance
---@param o? table Optional initial object
---@return Parser
function Parser:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

---Get visibility modifier of a node
---@param node TSNode The treesitter node of the visibility modifier
---@param bufnr integer The buffer number of the source file
---@return string visibility The visibility modifier of the node
function Parser.get_visibility(node, bufnr)
	error("Not implemented!")
end

---Parse a method node
---@param node TSNode The treesitter node of the method
---@param start_col integer Starting column of the node
---@param start_row integer Starting row of the node
---@param opts table Additional options
---@return table Method information
function Parser.parse_method(node, start_col, start_row, opts)
	error("Not implemented!")
end

---Parse a constant node
---@param node TSNode The treesitter node of the constant
---@param start_col integer Starting column of the node
---@param start_row integer Starting row of the node
---@param opts table Additional options
---@return table Constant information
function Parser.parse_constant(node, start_col, start_row, opts)
	error("Not implemented!")
end

---Parse a property node
---@param node TSNode The treesitter node of the property
---@param start_col integer Starting column of the node
---@param start_row integer Starting row of the node
---@param opts table Additional options
---@return table Property information
function Parser.parse_property(node, start_col, start_row, opts)
	error("Not implemented!")
end

return Parser

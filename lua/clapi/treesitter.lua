local utils = require("clapi.utils")
local parsers = require("nvim-treesitter.parsers")
local async = require("plenary.async")
local lsp = require("clapi.lsp")

-- Treesitter Parser Module
local M = {}

---@param lang string
---@param query_group string
function M.get_query(lang, query_group)
	-- TODO: nil check
	--
	local results = vim.api.nvim_get_runtime_file(string.format("queries/%s/%s.scm", lang, query_group), true)
	for i, value in ipairs(results) do
		if string.find(value, "clapi") then
			local fullpath = results[i]
			return utils.read_file(fullpath)
		end
	end
	return nil
end

---@param node TSNode The treesitter node of the visibility modifier
---@param bufnr integer The buffer number of the source file
---@return string visibility The visibility modifier of the node
local function get_visibility(node, bufnr)
	for n, _ in node:iter_children() do
		local type = n:type()
		if type == "visibility_modifier" then -- TODO: make this line language agnostic
			return vim.treesitter.get_node_text(n, bufnr)
		end
	end
	return "public" -- Public by default (TODO: review this wih more languages)
end

---@param node TSNode
---@param start_col integer
---@param start_row integer
---@param opts table
M.parse_method = function(node, start_col, start_row, opts)
	local visibility = get_visibility(node:parent(), opts.bufnr)
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

---@param node TSNode
---@param start_col integer
---@param start_row integer
---@param opts table
M.parse_constant = function(node, start_col, start_row, opts)
	local text = vim.treesitter.get_node_text(node, opts.bufnr)
	local visibility = get_visibility(node:parent():parent(), opts.bufnr)
	return {
		col = start_col + 1,
		filename = opts.filename,
		visibility = visibility,
		kind = "Method",
		lnum = start_row + 1,
		text = "[Constant] " .. opts.class_name .. text,
	}
end

---@param node TSNode
---@param start_col integer
---@param start_row integer
---@param opts table
M.parse_property = function(node, start_col, start_row, opts)
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

	local visibility = get_visibility(prop_parent, opts.bufnr)
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

---@param opts table
M.parse_file = async.wrap(function(opts, callback)
	opts = opts or {}
	opts.class_name = opts.class_name and string.format("%s::", opts.class_name) or ""

	if opts.filename and opts.bufnr then
		utils.notify("parse_file", {
			msg = "filename and bufnr params can't be used at the same time",
			level = "ERROR",
		})
		callback(nil)
		return
	end

	if opts.filename then
		opts.bufnr = vim.fn.bufadd(opts.filename)
	end

	if opts.bufnr then
		opts.filename = vim.api.nvim_buf_get_name(opts.bufnr)
	end

	if not opts.filetype then
		local filetype = utils.get_file_extension(opts.filename)
		if not filetype then
			utils.notify("parse_file", {
				msg = "Couldn't get the file extension",
				level = "ERROR",
			})
			callback(nil)
			return
		end
		opts.filetype = filetype
	end

	if opts.filetype == "" then
		utils.notify("parse_file", {
			msg = "No language detected",
			level = "ERROR",
		})
		callback(nil)
		return
	end

	opts.query_str = opts.query_str or M.get_query(opts.filetype, "locals")

	if not opts.query_str then
		utils.notify("parse_file", {
			msg = string.format("Language not supported (%s)", opts.filetype),
			level = "ERROR",
		})
		callback(nil)
		return
	end

	-- Ensure buffer is loaded
	if not vim.api.nvim_buf_is_loaded(opts.bufnr) and vim.fn.filereadable(opts.filename) == 1 then
		vim.fn.bufload(opts.bufnr)
	end

	-- Load the treesitter parser for the language
	local treesitter_filetype = parsers.get_buf_lang(opts.bufnr)
	local parser = vim.treesitter.get_parser(opts.bufnr, treesitter_filetype)
	if not parser then
		utils.notify("treesitter.parse_file", {
			msg = "No parser for the current buffer",
			level = "ERROR",
		})
		callback(nil)
		return
	end

	-- Parse the query
	local query = vim.treesitter.query.parse(opts.filetype, opts.query_str)
	if not query then
		utils.notify("treesitter.parse_file", {
			msg = "Failed to parse query",
			level = "ERROR",
		})
		callback(nil)
		return
	end

	-- Parse the content
	-- TODO: nil check
	local tree = parser:parse()
	if not tree then
		utils.notify("treesitter.parse_file", {
			msg = "Failed to parse buffer content",
			level = "ERROR",
		})
		callback(nil)
		return
	end

	tree = tree[1]

	local root = tree:root()

	-- Execute the query and collect results
	local result = {}

	-- First pass - collect all captures
	for id, node, _ in query:iter_captures(root, opts.bufnr) do
		local capture_name = query.captures[id]
		local start_row, start_col, _, _ = node:range()

		if capture_name == "method_name" then
			local method = M.parse_method(node, start_col, start_row, opts)
			table.insert(result, method)
		elseif capture_name == "prop_name" then
			local property = M.parse_property(node, start_col, start_row, opts)
			table.insert(result, property)
		elseif capture_name == "const_name" then
			local const = M.parse_constant(node, start_col, start_row, opts)
			table.insert(result, const)
		end
	end

	async.run(function()
		local parent_defs = M.get_parent_file({ bufnr = opts.bufnr })
		if not parent_defs then
			-- error already printed somewhere
			callback(result)
			return
		end
		for _, value in pairs(parent_defs) do
			table.insert(result, value)
		end

		callback(result)
	end)
end, 2)

---@param opts table
M.get_parent_file = async.wrap(function(opts, callback)
	opts = opts or {}
	opts.bufnr = opts.bufnr or 0

	local filetype = parsers.get_buf_lang(opts.bufnr)
	local parser = vim.treesitter.get_parser(opts.bufnr, filetype)
	if not parser then
		utils.notify("get_parent_file", {
			msg = "No parser for the current buffer",
			level = "ERROR",
		})
		callback(nil)
	end

	-- Parse the query
	-- WARNING: might have to use vim.bo.filetype instead of treesitter filetype
	local query_str = M.get_query(filetype, "parent")
	if not query_str then
		utils.notify("get_parent_file", {
			msg = string.format("Language not supported (%s)", filetype),
			level = "ERROR",
		})
		callback(nil)
	end

	local query = vim.treesitter.query.parse(filetype, query_str)

	if not query then
		utils.notify("get_parent_file", {
			msg = "Failed to parse query",
			level = "ERROR",
		})
		callback(nil)
	end

	-- Parse the content
	-- TODO: nil check
	local tree = parser:parse()
	if not tree then
		utils.notify("get_parent_file", {
			msg = "Failed to parse buffer content",
			level = "ERROR",
		})
		callback(nil)
	end

	tree = tree[1]

	local root = tree:root()

	local result = {}

	async.run(function()
		for id, node, metadata in query:iter_captures(root, opts.bufnr) do
			local capture_name = query.captures[id]
			if capture_name == "parent" then
				local line, char = node:start()
				char = char + 1
				local class_name = vim.treesitter.get_node_text(node, opts.bufnr)

				local filepath =
					lsp.get_file_from_position({ bufnr = opts.bufnr, position = { character = char, line = line } })
				if not filepath or filepath == "" then
					-- error already printed in get_file_from_position
					callback(nil)
				end
				local defs = M.parse_file({ filename = filepath, class_name = class_name })
				for _, value in pairs(defs) do
					if value["visibility"] ~= "private" then
						table.insert(result, value)
					end
				end
			end
		end
		callback(result)
	end)
end, 2)

return M

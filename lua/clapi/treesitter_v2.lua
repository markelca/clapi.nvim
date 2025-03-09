local utils = require("clapi.utils")
-- Treesitter Parser Module
local M = {}

-- Parse a file using treesitter and extract actual data
function M.parse_file(bufnr, query_str, filename, filetype)
	bufnr = bufnr or 0
	filename = filename or vim.api.nvim_buf_get_name(bufnr)
	filetype = filetype or vim.bo.filetype

	if filetype == "" then
		utils.notify("parse_file", {
			msg = "No language detected",
			level = "ERROR",
		})
		return
	end

	query_str = query_str or M.get_full_query(filetype)

	if not query_str then
		utils.notify("parse_file", {
			msg = string.format("Language not supported (%s)", filetype),
			level = "ERROR",
		})
		return
	end

	-- Ensure buffer is loaded
	if not vim.api.nvim_buf_is_loaded(bufnr) and vim.fn.filereadable(filename) == 1 then
		vim.fn.bufload(bufnr)
	end

	-- Load the treesitter parser for the language
	local parser = vim.treesitter.get_parser(bufnr, filetype)
	if not parser then
		error(string.format("Failed to load %s parser for buffer %s", filetype, bufnr))
		return {}
	end

	-- Parse the query
	local query = vim.treesitter.query.parse(filetype, query_str)
	if not query then
		error("Failed to parse query")
		return {}
	end

	-- Parse the content
	local tree = parser:parse()[1]
	if not tree then
		error("Failed to parse buffer content")
		return {}
	end

	local root = tree:root()

	-- Execute the query and collect results
	local result = {}
	local methods = {}
	local properties = {}
	local visibilities = {}

	-- First pass - collect all captures
	for id, node, metadata in query:iter_captures(root, bufnr) do
		local capture_name = query.captures[id]
		local text = vim.treesitter.get_node_text(node, bufnr)
		local start_row, start_col, _, _ = node:range()

		if capture_name == "method_name" then
			table.insert(methods, {
				name = text,
				node = node,
				row = start_row + 1,
				col = start_col + 1,
			})
		elseif capture_name == "prop_name" then
			table.insert(properties, {
				name = text,
				node = node,
				row = start_row + 1,
				col = start_col + 1,
			})
		elseif capture_name == "visibility" then
			table.insert(visibilities, {
				value = text,
				node = node,
				row = start_row + 1,
				col = start_col + 1,
			})
		end
	end

	-- Process methods and associate them with visibilities
	for _, method in ipairs(methods) do
		local parent = method.node:parent()
		local visibility = "public" -- Default visibility

		-- Find the closest visibility modifier
		for _, vis in ipairs(visibilities) do
			local vis_parent = vis.node:parent()
			if vis_parent == parent then
				visibility = vis.value
				break
			end
		end

		table.insert(result, {
			col = method.col,
			filename = filename,
			visibility = visibility,
			kind = "Method",
			lnum = method.row,
			text = "[Method] " .. method.name,
		})
	end

	-- Process properties and associate them with visibilities
	for _, prop in ipairs(properties) do
		local parent = prop.node:parent()
		local prop_parent = parent

		-- Find the parent property declaration or promotion parameter
		while
			prop_parent
			and prop_parent:type() ~= "property_declaration"
			and prop_parent:type() ~= "property_promotion_parameter"
		do
			prop_parent = prop_parent:parent()
		end

		local visibility = "private" -- Default visibility

		-- Find the closest visibility modifier
		for _, vis in ipairs(visibilities) do
			local vis_parent = vis.node:parent()
			if vis_parent == prop_parent then
				visibility = vis.value
				break
			end
		end

		table.insert(result, {
			col = prop.col,
			filename = filename,
			visibility = visibility,
			kind = "Property",
			lnum = prop.row,
			text = "[Property] " .. prop.name,
		})
	end

	return result
end

---@param lang string
---@return string[]
function M.runtime_queries(lang)
	return vim.api.nvim_get_runtime_file(string.format("queries/%s.scm", lang), true)
end

-- Method 2: Using Neovim's API (preferred for Neovim plugins)
local function read_file(path)
	-- Check if the file exists
	if vim.fn.filereadable(path) == 0 then
		return nil
	end

	-- Read the file into a table where each line is an element
	local lines = vim.fn.readfile(path)

	-- Join the lines with newline characters
	local content = table.concat(lines, "\n")
	return content
end

function M.get_full_query(lang)
	local fullpath = M.runtime_queries(lang)[1]
	return read_file(fullpath)
end

-- Generate output as a lookupable table
function M.get_symbols(bufnr, query_str)
	bufnr = bufnr or 0
	query_str = query_str or M.get_full_query()

	vim.print("1111")

	local filename = vim.api.nvim_buf_get_name(bufnr)
	local entries = M.parse_file(bufnr, query_str, filename)

	-- Organize by kind for easy lookup
	local by_kind = {}
	for _, entry in ipairs(entries) do
		by_kind[entry.kind] = by_kind[entry.kind] or {}
		table.insert(by_kind[entry.kind], entry)
	end

	-- Organize by line number
	local by_line = {}
	for _, entry in ipairs(entries) do
		by_line[entry.lnum] = by_line[entry.lnum] or {}
		table.insert(by_line[entry.lnum], entry)
	end

	return {
		all = entries,
		by_kind = by_kind,
		by_line = by_line,
	}
end

return M

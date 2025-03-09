local utils = require("clapi.utils")
local parsers = require("nvim-treesitter.parsers")
-- Treesitter Parser Module
local M = {}

-- Parse a file using treesitter and extract actual data
function M.parse_file(opts)
	opts.bufnr = opts.bufnr or 0
	opts.filename = opts.filename or vim.api.nvim_buf_get_name(opts.bufnr)
	opts.filetype = opts.filetype or vim.bo.filetype

	if opts.filetype == "" then
		utils.notify("parse_file", {
			msg = "No language detected",
			level = "ERROR",
		})
		return
	end

	opts.query_str = opts.query_str or M.get_full_query(opts.filetype)

	if not opts.query_str then
		utils.notify("parse_file", {
			msg = string.format("Language not supported (%s)", opts.filetype),
			level = "ERROR",
		})
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
		return
	end

	-- Parse the query
	local query = vim.treesitter.query.parse(opts.filetype, opts.query_str)
	if not query then
		utils.notify("treesitter.parse_file", {
			msg = "Failed to parse query",
			level = "ERROR",
		})
		return {}
	end

	-- Parse the content
	-- TODO: nil check
	local tree = parser:parse()
	if not tree then
		utils.notify("treesitter.parse_file", {
			msg = "Failed to parse buffer content",
			level = "ERROR",
		})
		return
	end

	tree = tree[1]

	local root = tree:root()

	-- Execute the query and collect results
	local result = {}
	local methods = {}
	local properties = {}
	local visibilities = {}

	-- First pass - collect all captures
	for id, node, metadata in query:iter_captures(root, opts.bufnr) do
		local capture_name = query.captures[id]
		local text = vim.treesitter.get_node_text(node, opts.bufnr)
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
			filename = opts.filename,
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
			filename = opts.filename,
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

function M.get_full_query(lang)
	-- TODO: nil check
	local fullpath = M.runtime_queries(lang)[1]
	return utils.read_file(fullpath)
end

return M

local utils = require("clapi.utils")
local __get_query = require("clapi.parser.__get_query")
local tsparsers = require("nvim-treesitter.parsers")
local async = require("plenary.async")
local lsp = require("clapi.lsp")

---@class ParserModule
local M = {}

---Get a parser for a specific language
---@param lang string Language name
---@return Parser|nil
local function get_parser(lang)
	if not lang then
		utils.notify("Parser.fromLang", {
			level = "ERROR",
			msg = "Lang not provided",
		})
		return
	end

	---@type table<string, Parser>
	local parsers = {
		["php"] = require("clapi.parser.__parser_php"),
		["java"] = require("clapi.parser.__parser_java"),
	}

	local parser = parsers[lang]

	if not parser then
		utils.notify("parsers.get_parser", {
			level = "ERROR",
			msg = "No parser available for language " .. lang,
		})
		return
	end

	return parser:new()
end

---Get parent class file and parse its definitions
---@param opts table Options for parsing
---@param opts.bufnr? integer Buffer number, defaults to current buffer (0)
---@return table|nil definitions List of definitions from parent class or nil if error
local get_parent_file = async.wrap(function(opts, callback)
	opts = opts or {}
	opts.bufnr = opts.bufnr or 0

	local filetype = tsparsers.get_buf_lang(opts.bufnr)
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
	local query_str = __get_query(filetype, "parent")
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
		for id, node, _ in query:iter_captures(root, opts.bufnr) do
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

---Parse a file for LSP symbols
---@param opts table Options for parsing
---@param opts.filename? string Path to the file (cannot be used with bufnr)
---@param opts.bufnr? integer Buffer number (cannot be used with filename)
---@param opts.class_name? string Name of the class to filter results
---@param opts.filetype? string Force filetype instead of detecting from extension
---@param opts.query_str? string Custom query string instead of loading from queries
---@return table|nil results List of symbols found or nil if error
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

	opts.query_str = opts.query_str or __get_query(opts.filetype, "locals")

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
	local treesitter_filetype = tsparsers.get_buf_lang(opts.bufnr)

	local parser = get_parser(treesitter_filetype)

	if not parser then
		utils.notify("parser.parse_file", {
			msg = "No parser for the current buffer",
			level = "ERROR",
		})
		callback(nil)
		return
	end

	local ts_fileparser = vim.treesitter.get_parser(opts.bufnr, treesitter_filetype)
	if not ts_fileparser then
		utils.notify("parser.parse_file", {
			msg = "No treesitter parser for the current buffer",
			level = "ERROR",
		})
		callback(nil)
		return
	end

	-- Parse the query
	local query = vim.treesitter.query.parse(opts.filetype, opts.query_str)
	if not query then
		utils.notify("parser.parse_file", {
			msg = "Failed to parse query",
			level = "ERROR",
		})
		callback(nil)
		return
	end

	-- Parse the content
	-- TODO: nil check
	local tree = ts_fileparser:parse()
	if not tree then
		utils.notify("parser.parse_file", {
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
			local method = parser.parse_method(node, start_col, start_row, opts)
			table.insert(result, method)
		elseif capture_name == "prop_name" then
			local property = parser.parse_property(node, start_col, start_row, opts)
			table.insert(result, property)
		elseif capture_name == "const_name" then
			local const = parser.parse_constant(node, start_col, start_row, opts)
			table.insert(result, const)
		end
	end

	async.run(function()
		local parent_defs = get_parent_file({ bufnr = opts.bufnr })
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

return M

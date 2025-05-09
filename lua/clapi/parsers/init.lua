local utils = require("clapi.utils")
local tsparsers = require("nvim-treesitter.parsers")
local async = require("plenary.async")
local lsp = require("clapi.lsp")

---@class Parser
local Parser = {}

function Parser:new(o)
	o = o or {} -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

function Parser:hi()
	error("Not implemented!")
end
---
---@param node TSNode The treesitter node of the visibility modifier
---@param bufnr integer The buffer number of the source file
---@return string visibility The visibility modifier of the node
function Parser:get_visibility(node, bufnr)
	error("Not implemented!")
end
---
---@param node TSNode
---@param start_col integer
---@param start_row integer
---@param opts table
function Parser:parse_method(node, start_col, start_row, opts)
	error("Not implemented!")
end

---@param node TSNode
---@param start_col integer
---@param start_row integer
---@param opts table
function Parser:parse_constant(node, start_col, start_row, opts)
	error("Not implemented!")
end

---@param node TSNode
---@param start_col integer
---@param start_row integer
---@param opts table
function Parser:parse_property(node, start_col, start_row, opts)
	error("Not implemented!")
end

---@param lang string
---@return Parser|nil
function Parser.get_parser(lang)
	if not lang then
		utils.notify("Parser.fromLang", {
			level = "ERROR",
			msg = "Lang not provided",
		})
		return
	end

	local parsers = {
		["php"] = require("clapi.parsers.php"),
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
---
---@param lang string
---@param query_group string
function Parser.get_query(lang, query_group)
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

---@param opts table
Parser.parse_file = async.wrap(function(opts, callback)
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

	opts.query_str = opts.query_str or Parser.get_query(opts.filetype, "locals")

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

	local parser = Parser.get_parser(treesitter_filetype)

	if not parser then
		utils.notify("treesitter.parse_file", {
			msg = "No parser for the current buffer",
			level = "ERROR",
		})
		callback(nil)
		return
	end

	local ts_fileparser = vim.treesitter.get_parser(opts.bufnr, treesitter_filetype)
	if not ts_fileparser then
		utils.notify("treesitter.parse_file", {
			msg = "No treesitter parser for the current buffer",
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
	local tree = ts_fileparser:parse()
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
			local method = parser:parse_method(node, start_col, start_row, opts)
			table.insert(result, method)
		elseif capture_name == "prop_name" then
			local property = parser:parse_property(node, start_col, start_row, opts)
			table.insert(result, property)
		elseif capture_name == "const_name" then
			local const = parser:parse_constant(node, start_col, start_row, opts)
			table.insert(result, const)
		end
	end

	async.run(function()
		local parent_defs = parser.get_parent_file({ bufnr = opts.bufnr })
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
Parser.get_parent_file = async.wrap(function(opts, callback)
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
	local query_str = Parser.get_query(filetype, "parent")
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
				local defs = Parser.parse_file({ filename = filepath, class_name = class_name })
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

return Parser

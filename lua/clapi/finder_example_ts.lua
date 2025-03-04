local utils = require("telescope.utils")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local entry_display = require("telescope.pickers.entry_display")

local treesitter_type_highlight = {
	["associated"] = "TSConstant",
	["constant"] = "TSConstant",
	["field"] = "TSField",
	["function"] = "TSFunction",
	["method"] = "TSMethod",
	["parameter"] = "TSParameter",
	["property"] = "TSProperty",
	["struct"] = "Struct",
	["var"] = "TSVariableBuiltin",
}

local files = {}

local function prepare_match(entry, kind)
	local entries = {}

	if entry.node then
		table.insert(entries, entry)
	else
		for name, item in pairs(entry) do
			vim.list_extend(entries, prepare_match(item, name))
		end
	end

	return entries
end

local get_filename_fn = function()
	local bufnr_name_cache = {}
	return function(bufnr)
		bufnr = vim.F.if_nil(bufnr, 0)
		local c = bufnr_name_cache[bufnr]
		if c then
			return c
		end

		local n = vim.api.nvim_buf_get_name(bufnr)
		bufnr_name_cache[bufnr] = n
		return n
	end
end

local function gen_from_treesitter(opts)
	opts = opts or {}

	local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()

	local display_items = {
		{ width = opts.symbol_width or 25 },
		{ width = 10 },
		{ remaining = true },
	}

	if opts.show_line then
		table.insert(display_items, 2, { width = 6 })
	end

	local displayer = entry_display.create({
		separator = " ",
		items = display_items,
	})

	local type_highlight = opts.symbol_highlights or treesitter_type_highlight

	local make_display = function(entry)
		local msg = vim.api.nvim_buf_get_lines(bufnr, entry.lnum, entry.lnum, false)[1] or ""
		msg = vim.trim(msg)

		local display_columns = {
			entry.text,
			{ entry.kind, type_highlight[entry.kind], type_highlight[entry.kind] },
			msg,
		}
		if opts.show_line then
			table.insert(display_columns, 2, { entry.lnum .. ":" .. entry.col, "TelescopeResultsLineNr" })
		end

		return displayer(display_columns)
	end
	local get_filename = get_filename_fn()
	return function(entry)
		local start_row, start_col, end_row, _ = vim.treesitter.get_node_range(entry.node)
		local node_text = vim.treesitter.get_node_text(entry.node, bufnr)
		return make_entry.set_default_entry_mt({
			value = entry.node,
			kind = entry.kind,
			ordinal = node_text .. " " .. (entry.kind or "unknown"),
			display = make_display,

			node_text = node_text,

			filename = get_filename(bufnr),
			-- need to add one since the previewer substacts one
			lnum = start_row + 1,
			col = start_col,
			text = node_text,
			start = start_row,
			finish = end_row,
		}, opts)
	end
end

files.treesitter = function(opts)
	opts.show_line = vim.F.if_nil(opts.show_line, true)

	local has_nvim_treesitter, _ = pcall(require, "nvim-treesitter")
	if not has_nvim_treesitter then
		utils.notify("builtin.treesitter", {
			msg = "This picker requires nvim-treesitter",
			level = "ERROR",
		})
		return
	end

	local parsers = require("nvim-treesitter.parsers")
	if not parsers.has_parser(parsers.get_buf_lang(opts.bufnr)) then
		utils.notify("builtin.treesitter", {
			msg = "No parser for the current buffer",
			level = "ERROR",
		})
		return
	end

	local ts_locals = require("nvim-treesitter.locals")
	-- print(vim.inspect(ts_locals))
	-- print(vim.inspect(ts_locals))
	local results = {}
	for _, definition in ipairs(ts_locals.get_definitions(opts.bufnr)) do
		local entries = prepare_match(ts_locals.get_local_nodes(definition))
		for _, entry in ipairs(entries) do
			entry.kind = vim.F.if_nil(entry.kind, "")
			table.insert(results, entry)
		end
	end

	results = utils.filter_symbols(results, opts)
	if vim.tbl_isempty(results) then
		-- error message already printed in `utils.filter_symbols`
		return
	end

	if vim.tbl_isempty(results) then
		return
	end

	pickers
		.new(opts, {
			prompt_title = "Treesitter Symbols",
			finder = finders.new_table({
				results = results,
				entry_maker = opts.entry_maker or gen_from_treesitter(opts),
			}),
			previewer = conf.grep_previewer(opts),
			sorter = conf.prefilter_sorter({
				tag = "kind",
				sorter = conf.generic_sorter(opts),
			}),
			push_cursor_on_edit = true,
		})
		:find()
end

files.treesitter({ bufnr = 2 })

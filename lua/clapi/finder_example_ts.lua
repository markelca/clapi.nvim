local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local make_entry = require("clapi.make_entry")
local ts_v3 = require("clapi.ts_v3")
--------------------------------------------------------
-- Telescope functions end
--------------------------------------------------------

local example = {}

example.picker = function(opts)
	opts.path_display = { "hidden" }

	return pickers
		.new(opts, {
			prompt_title = "LSP Document Symbols",
			finder = finders.new_table({
				results = ts_v3.parse_php_file(opts.bufnr),
				entry_maker = opts.entry_maker or make_entry.gen_from_lsp_symbols(opts),
			}),
			previewer = conf.qflist_previewer(opts),
			sorter = conf.prefilter_sorter({
				tag = "symbol_type",
				sorter = conf.generic_sorter(opts),
			}),
			push_cursor_on_edit = true,
			push_tagstack_on_edit = true,
		})
		:find()
end

example.picker({ bufnr = 16 })

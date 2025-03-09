local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local make_entry = require("clapi.make_entry")
local treesitter = require("clapi.treesitter_v2")

local M = {}

M.builtin = function(opts)
	opts = opts or {}
	opts.bufnr = opts.bufnr or 0
	opts.path_display = { "hidden" }
	local results = treesitter.parse_file(opts)
	if not results then
		-- error message already printed inside the `parse_file` function
		return
	end

	return pickers
		.new(opts, {
			prompt_title = "Module Interface",
			finder = finders.new_table({
				results = results,
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

return M

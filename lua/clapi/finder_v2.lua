local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local make_entry = require("clapi.make_entry")
local treesitter = require("clapi.treesitter_v2")
--------------------------------------------------------
-- Telescope functions end
--------------------------------------------------------
local php_query = [[
    (method_declaration
      (visibility_modifier) @visibility
      name: (name) @method_name
    )
    (property_promotion_parameter
      visibility: (visibility_modifier) @visibility
      name: (variable_name) @prop_name
    )
  ]]

local M = {}

M.builtin = function(opts)
	opts = opts or {}
	opts.bufnr = opts.bufnr or 0
	opts.path_display = { "hidden" }
	local results = treesitter.parse_file(opts.bufnr)
	if not results then
		return
	end

	return pickers
		.new(opts, {
			prompt_title = "LSP Document Symbols",
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

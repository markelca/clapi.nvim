local telescope_config = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local make_entry = require("clapi.make_entry")
local parser = require("clapi.parser.init")
local async = require("plenary.async")

---@class FinderModule
local M = {}

---Build and display a telescope picker with module interface
---@param opts? table Configuration options
---@param opts.bufnr? integer Buffer number, defaults to current buffer (0)
---@param opts.path_display? table|string How to display paths
---@param opts.entry_maker? function Custom entry maker function
---@param opts.show_inherited? boolean Show inherited members, defaults to true
---@param opts.visibility? string Filter by visibility (public, protected, private), defaults to nil (all)
---@return nil
M.builtin = function(opts)
	-- vim.print(opts)
	opts = opts or {}
	opts.bufnr = opts.bufnr or 0
	opts.path_display = { "hidden" }

	async.run(function()
		local results = parser.parse_file(opts)
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
				previewer = telescope_config.qflist_previewer(opts),
				sorter = telescope_config.prefilter_sorter({
					tag = "symbol_type",
					sorter = telescope_config.generic_sorter(opts),
				}),
				push_cursor_on_edit = true,
				push_tagstack_on_edit = true,
			})
			:find()
	end)
end

return M

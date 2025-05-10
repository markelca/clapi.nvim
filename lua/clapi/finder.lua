local conf = require("telescope.config").values
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
---@return nil
M.builtin = function(opts)
	opts = opts or {}
	opts.bufnr = opts.bufnr or 0
	opts.path_display = { "hidden" }

	-- Get extension configuration
	local telescope_config = require("telescope.config").values
	local ext_config = telescope_config.extensions and telescope_config.extensions.clapi or {}

	-- Set show_inherited default value (true if not specified)
	opts.show_inherited = vim.F.if_nil(opts.show_inherited, ext_config.show_inherited, true)

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
				previewer = conf.qflist_previewer(opts),
				sorter = conf.prefilter_sorter({
					tag = "symbol_type",
					sorter = conf.generic_sorter(opts),
				}),
				push_cursor_on_edit = true,
				push_tagstack_on_edit = true,
			})
			:find()
	end)
end

return M

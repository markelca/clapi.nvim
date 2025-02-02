local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")
local treesitter = require("clapi.treesitter")
local previewers = require("telescope.previewers")

local M = {}

local builtin = function(opts)
	opts = opts or {}
	local results = treesitter.search(0)

	local picker_opts = {
		prompt_title = "Complex Builtin",
		finder = finders.new_table({
			results = results,
			entry_maker = function(entry)
				local displayer = entry_display.create({
					separator = " ",
					items = {
						{ width = 10 },
						{ width = 10 },
						{ remaining = true },
					},
				})

				local make_display = function()
					return displayer({
						{ entry.visibility },
						{ entry.type },
						{ entry.name },
					})
				end

				local searchable =
					string.format("%s %s %s", entry.visibility or "", entry.type or "", entry.name or ""):lower()
				return {
					value = entry,
					display = make_display,
					ordinal = searchable,
					type = entry.type,
				}
			end,
		}),
		sorter = conf.generic_sorter(opts),
		attach_mappings = function(prompt_bufnr, map)
			-- Complex custom actions
			actions.select_default:replace(function()
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				print(selection["value"]["name"])
				-- Do something with the selection
			end)
			return true
		end,
	}

	-- Finally create the picker with all the configuration
	return pickers.new(opts, picker_opts):find()
end

M.builtin = builtin

return M

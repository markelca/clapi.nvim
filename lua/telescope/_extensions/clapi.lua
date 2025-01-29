local has_telescope, telescope = pcall(require, "telescope")

if not has_telescope then
	error("This plugin requires nvim-telescope/telescope.nvim")
end

-- Create the Telescope picker
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
-- Your custom picker function
local function custom_picker(opts)
	opts = opts or {}

	local results = {
		{ value = "Result 1", info = "Additional info 1" },
		{ value = "Result 2", info = "Additional info 2" },
	}

	pickers
		.new(opts, {
			prompt_title = "Custom Results",
			finder = finders.new_table({
				results = results,
				entry_maker = function(entry)
					return {
						value = entry,
						display = entry.value,
						ordinal = entry.value,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					print("Selected: " .. selection.value.value)
					print("Info: " .. selection.value.info)
				end)
				return true
			end,
		})
		:find()
end

-- Register the extension
return telescope.register_extension({
	exports = {
		custom_picker = custom_picker,
	},
})

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

-- This is a picker - it's the basic display mechanism
local function custom_picker(opts)
	opts = opts or {}
	pickers
		.new(opts, {
			prompt_title = "Basic Picker",
			finder = finders.new_table({
				results = { "Result 1", "Result 2" },
			}),
			sorter = conf.generic_sorter(opts),
		})
		:find()
end

-- This is a builtin - it's a more complete feature that might use multiple pickers
local builtin = function(opts)
	opts = opts or {}

	-- You might have some setup logic here
	local results = {}

	-- Maybe determine which type of picker to show based on context
	if opts.mode == "simple" then
		results = { "Simple 1", "Simple 2" }
	else
		results = {
			{ name = "Complex 1", type = "feature" },
			{ name = "Complex 2", type = "bug" },
		}
	end

	-- You might have multiple picker configurations
	local picker_opts = {
		prompt_title = "Complex Builtin",
		finder = finders.new_table({
			results = results,
			entry_maker = function(entry)
				if type(entry) == "string" then
					return {
						value = entry,
						display = entry,
						ordinal = entry,
					}
				else
					return {
						value = entry,
						display = entry.name,
						ordinal = entry.name,
						type = entry.type,
					}
				end
			end,
		}),
		sorter = conf.generic_sorter(opts),
		attach_mappings = function(prompt_bufnr, map)
			-- Complex custom actions
			actions.select_default:replace(function()
				local selection = action_state.get_selected_entry()
				actions.close(prompt_bufnr)
				-- Do something with the selection
			end)
			return true
		end,
	}

	-- You might add previewer configuration
	if opts.preview then
		picker_opts.previewer = conf.file_previewer(opts)
	end

	-- Finally create the picker with all the configuration
	return pickers.new(opts, picker_opts):find()
end

-- Register both as part of your extension
return require("telescope").register_extension({
	exports = {
		custom_picker = custom_picker, -- Simple picker
		my_builtin = builtin, -- More complex builtin
	},
})

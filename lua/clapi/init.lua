local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local treesitter = require("clapi.treesitter")
local finder_ts = require("clapi.finder_example_ts")

local clapi = {}
local clapi_v2 = {}

clapi_v2.builtin = finder_ts.picker

local searchable = function(entry)
	local searchable = ""
	for _, value in pairs(entry) do
		searchable = searchable .. value
	end
	return searchable
end

clapi.builtin = function(opts)
	opts = opts or {}
	local results = treesitter.search(0)
	if results == nil then
		return
	end

	pickers
		.new(opts, {
			prompt_title = "Document Symbols",
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

					return {
						value = entry,
						display = make_display,
						ordinal = searchable(entry),
						type = entry.type,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
		})
		:find()
end

-- return clapi
return clapi_v2

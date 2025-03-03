local conf = require("telescope.config").values
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local make_entry = require("clapi.make_entry")
--------------------------------------------------------
-- Telescope functions end
--------------------------------------------------------

local example = {}

local test_entry = {
	{
		col = 11,
		filename = "/home/markel/estudio/hex/php-ddd-example/src/Mooc/Courses/Domain/Course.php",
		visibility = "",
		kind = "Namespace",
		lnum = 5,
		text = "[Namespace] CodelyTv\\Mooc\\Courses\\Domain",
	},
	{
		col = 13,
		filename = "/home/markel/estudio/hex/php-ddd-example/src/Mooc/Courses/Domain/Course.php",
		kind = "Class",
		visibility = "public",
		lnum = 10,
		text = "[Class] Course",
	},
	{
		col = 56,
		filename = "/home/markel/estudio/hex/php-ddd-example/src/Mooc/Courses/Domain/Course.php",
		kind = "Property",
		visibility = "private",
		lnum = 12,
		text = "[Property] $id",
	},
	{
		col = 80,
		filename = "/home/markel/estudio/hex/php-ddd-example/src/Mooc/Courses/Domain/Course.php",
		kind = "Property",
		visibility = "private",
		lnum = 12,
		text = "[Property] $name",
	},
}

example.picker = function(opts)
	opts.path_display = { "hidden" }

	return pickers
		.new(opts, {
			prompt_title = "LSP Document Symbols",
			finder = finders.new_table({
				results = test_entry,
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

example.picker({})

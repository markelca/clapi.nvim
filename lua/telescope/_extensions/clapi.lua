-- Register both as part of your extension
-- local x = require("clapi").builtin
local telescope = require("telescope")

return telescope.register_extension({
	exports = {
		clapi = require("clapi").builtin, -- More complex builtin
	},
})

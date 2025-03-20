local ts = require("clapi.treesitter")
local async = require("plenary.async")

async.run(function()
	local file_path = ts.get_file_from_position({
		position = { line = 9, character = 27 },
		bufnr = 4,
	})
	if file_path then
		print("Found file:", file_path)
	end
end)

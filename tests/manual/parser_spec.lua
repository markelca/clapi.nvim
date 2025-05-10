local lsp = require("clapi.lsp")
local async = require("plenary.async")

-- async.run(function()
-- 	local file_path = lsp.get_file_from_position({
-- 		position = { line = 9, character = 27 },
-- 		bufnr = 6,
-- 	})
-- 	if file_path then
-- 		print("Found file:", file_path)
-- 	end
-- end)

local utils = require("clapi.utils")

---Get a treesitter query for a specific language and query group
---@param lang string The language to get the query for
---@param query_group string The query group name (e.g., "locals", "parent")
---@return string|nil query The query string or nil if not found
return function(lang, query_group)
	-- TODO: nil check
	local results = vim.api.nvim_get_runtime_file(string.format("queries/%s/%s.scm", lang, query_group), true)
	for i, value in ipairs(results) do
		if string.find(value, "clapi") then
			local fullpath = results[i]
			return utils.read_file(fullpath)
		end
	end
	return nil
end

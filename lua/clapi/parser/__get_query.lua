local utils = require("clapi.utils")

---@param lang string
---@param query_group string
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

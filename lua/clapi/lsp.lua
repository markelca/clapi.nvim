local utils = require("clapi.utils")
local async = require("plenary.async")

local M = {}

---@param opts table
M.get_file_from_position = async.wrap(function(opts, callback)
	opts = opts or {}
	opts.bufnr = opts.bufnr or 0

	if not opts.position then
		utils.notify("get_file_from_position", {
			msg = "Position not provided",
			level = "ERROR",
		})
		callback(nil)
		return
	end

	vim.lsp.buf_request(opts.bufnr, "textDocument/definition", {
		position = opts.position,
		textDocument = {
			uri = string.format("file://%s", vim.api.nvim_buf_get_name(opts.bufnr)),
		},
	}, function(err, result, _, _)
		if err or not result then
			utils.notify("get_parent_file", {
				msg = "Couldn't get the file for the parent class",
				level = "ERROR",
			})
			callback(nil)
			return
		end

		for _, x in pairs(result) do
			-- Handle different LSP response formats
			local uri
			-- Handle array of results (typical for "textDocument/definition")
			if type(x) == "table" and x ~= nil then
				if x.uri then
					uri = x.uri
				elseif x.targetUri then
					uri = x.targetUri
				end
			-- Handle single result
			elseif type(x) == "table" and x.uri then
				uri = x.uri
			-- Handle phpactor-style nested result
			elseif type(x) == "table" and x.result and x.result.uri then
				uri = x.result.uri
			end

			if uri then
				callback(uri:gsub("file://", ""))
				return
			end
		end

		callback(nil)
	end)
end, 2)

return M

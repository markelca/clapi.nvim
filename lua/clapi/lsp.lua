local utils = require("clapi.utils")
local async = require("plenary.async_lib")

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

		local uri = result.uri or result[1].uri or result[1].targetUri

		if uri then
			callback(vim.uri_to_fname(uri))
		else
			callback(nil)
		end
	end)
end, 2)

return M

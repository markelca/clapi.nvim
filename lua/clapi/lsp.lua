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

	-- print(table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n"))
	local params = {
		position = opts.position,
		textDocument = {
			uri = string.format("file://%s", vim.api.nvim_buf_get_name(opts.bufnr)),
		},
	}
	-- vim.print(vim.lsp.buf_request_sync(opts.bufnr, "textDocument/documentSymbol", {
	-- 	position = {
	-- 		character = 28,
	-- 		line = 9,
	-- 	},
	-- 	textDocument = {
	-- 		uri = "file:///home/markel/estudio/lua/clapi.nvim/tests/clapi/resources/code/php/php-ddd-example/src/Mooc/Courses/Domain/Course.php",
	-- 	},
	-- }))
	vim.print("LSP attached:", vim.lsp.buf_is_attached(0, 1))
	-- vim.print("syms", vim.lsp.buf_request_sync(0, "workspace/symbol", { query = "*" }))
	-- vim.print(vim.lsp.buf_request_sync(0, "workspace/symbol", { query = "AggregateRoot" }))
	vim.print(params)
	vim.lsp.buf_request(opts.bufnr, "textDocument/definition", {
		position = opts.position,
		textDocument = {
			uri = string.format("file://%s", vim.api.nvim_buf_get_name(opts.bufnr)),
		},
	}, function(err, result, _, _)
		vim.print("resuuult")
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
	vim.print("ending func")
end, 2)

return M

local utils = require("clapi.utils")
local async = require("plenary.async")

---@class LSPModule
local M = {}

---Gets a file path from a position using LSP
---@param opts table Options for the LSP definition request
---@param opts.bufnr? integer Buffer number, defaults to current buffer (0)
---@param opts.position table The position in the buffer {line, character}
---@param opts.position.line integer Line number (0-indexed)
---@param opts.position.character integer Character/column position (0-indexed)
---@return string|nil filepath The file path or nil if not found
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

	local clients = vim.lsp.get_clients({ bufnr = opts.bufnr })
	if #clients == 0 then
		utils.notify("get_file_from_position", {
			msg = "Lsp is not attached",
			level = "ERROR",
		})
		callback(nil)
		return
	end

	local callback_called = false

	---Safe callback to prevent multiple callbacks
	---@param result string|nil The file path or nil
	---FIX: Accumulate results on multiple callbacks instead of ignoring them
	local function safe_callback(result)
		if not callback_called then
			callback_called = true
			callback(result)
		else
			utils.notify("lsp.get_file_from_position.safe_callback", {
				msg = "get_file_from_position ignored (extra callback)",
				level = "WARN",
			})
		end
	end

	vim.lsp.buf_request_all(opts.bufnr, "textDocument/definition", {
		position = opts.position,
		textDocument = {
			uri = string.format("file://%s", vim.api.nvim_buf_get_name(opts.bufnr)),
		},
	}, function(results)
		for _, result_entry in pairs(results) do
			if result_entry.error then
				utils.notify("get_parent_file", {
					msg = "Couldn't get the file for the parent class: " .. result_entry.error.message,
					level = "ERROR",
				})
				callback(nil)
				return
			else
				if result_entry.result == nil then
					utils.notify("get_parent_file", {
						msg = "Couldn't get the file for the parent class",
						level = "WARN",
					})
				else
					local result = result_entry.result

					local uri = result.uri or result[1].uri or result[1].targetUri

					if uri then
						safe_callback(vim.uri_to_fname(uri))
					else
						safe_callback(nil)
					end
				end
			end
		end
	end)
end, 2)

return M

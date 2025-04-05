local opts = {
	bufnr = 12,
	position = {
		character = 28,
		line = 9,
	},
}
local params = {
	position = opts.position,
	textDocument = {
		uri = string.format("file://%s", vim.api.nvim_buf_get_name(opts.bufnr)),
	},
}
local x = vim.lsp.buf_request_sync(opts.bufnr, "textDocument/definition", params)
vim.print(x)

local function get_file(opts)
	opts = opts or {}
	opts.bufnr = opts.bufnr or 0

	if not opts.position then
		error("Need to provide a position")
		return
	end

	local results = vim.lsp.buf_request_sync(opts.bufnr, "textDocument/definition", {
		position = opts.position,
		textDocument = {
			uri = string.format("file://%s", vim.api.nvim_buf_get_name(opts.bufnr)),
		},
	}, 1000)
	for _, x in pairs(results) do
		if x.result then
			for _, symbol in ipairs(x.result) do
				local uri = symbol.targetUri
				if uri then
					return uri:gsub("file://", "")
				end
			end
		end
	end
end

local p = get_file({ bufnr = 4, position = { character = 27, line = 9 } })
vim.print(p)

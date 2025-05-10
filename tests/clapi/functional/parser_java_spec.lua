local parser = require("clapi.parser.init")
local t = require("plenary.async.tests")

t.describe("parser.parse_file", function()
	t.it("should parse methods and properties from a Java file", function()
		local src_root_dir = vim.fn.getcwd() .. "/tests/clapi/functional/resources/code/java/example/src"
		local filename = src_root_dir .. "/com/example/course/Course.java"
		vim.cmd("edit " .. filename)
		local bufnr = vim.api.nvim_get_current_buf()
		local client_id = vim.lsp.start({
			name = "jdtls",
			cmd = { "jdtls" },
			root_dir = src_root_dir,
			capabilities = vim.lsp.protocol.make_client_capabilities(),
		})
		vim.lsp.buf_attach_client(bufnr, client_id)
		vim.wait(15000)

		local result = parser.parse_file({
			bufnr = bufnr,
			show_inherited = true,
		})

		local expected = {
			{
				col = 23,
				filename = src_root_dir .. "/com/example/course/Course.java",
				kind = "Property",
				lnum = 8,
				text = "[Property] id",
				visibility = "private",
			},
			{
				col = 20,
				filename = src_root_dir .. "/com/example/course/Course.java",
				kind = "Property",
				lnum = 9,
				text = "[Property] name",
				visibility = "private",
			},
			{
				col = 25,
				filename = src_root_dir .. "/com/example/course/Course.java",
				kind = "Property",
				lnum = 10,
				text = "[Property] duration",
				visibility = "private",
			},
			{
				col = 38,
				filename = src_root_dir .. "/com/example/course/Course.java",
				kind = "Property",
				lnum = 11,
				text = "[Property] att",
				visibility = "public",
			},
			{
				col = 12,
				filename = src_root_dir .. "/com/example/course/Course.java",
				kind = "Function",
				lnum = 13,
				text = "[Function] Course",
				visibility = "public",
			},
			{
				col = 17,
				filename = src_root_dir .. "/com/example/course/Course.java",
				kind = "Function",
				lnum = 19,
				text = "[Function] foo",
				visibility = "public",
			},
			{
				col = 12,
				filename = src_root_dir .. "/com/example/course/Course.java",
				kind = "Function",
				lnum = 22,
				text = "[Function] bar",
				visibility = "private",
			},
			{
				col = 16,
				filename = src_root_dir .. "/com/example/course/Course.java",
				kind = "Function",
				lnum = 26,
				text = "[Function] fizz",
				visibility = "public",
			},
			{
				col = 26,
				filename = src_root_dir .. "/com/example/shared/AggregateRoot.java",
				kind = "Function",
				lnum = 9,
				text = "[Function] AggregateRoot::record",
				visibility = "protected",
			},
			{
				col = 31,
				filename = src_root_dir .. "/com/example/shared/AggregateRoot.java",
				kind = "Function",
				lnum = 13,
				text = "[Function] AggregateRoot::pullDomainEvents",
				visibility = "public",
			},
		}

		assert.are.same(expected, result)
	end)
end)

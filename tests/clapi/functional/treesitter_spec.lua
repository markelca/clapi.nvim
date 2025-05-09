local treesitter = require("clapi.parsers.current")
local t = require("plenary.async.tests")

t.describe("treesitter.parse_file", function()
	t.it("should parse methods from a PHP file", function()
		local src_root_dir = vim.fn.getcwd() .. "/tests/clapi/functional/resources/code/php/example/src"
		local filename = src_root_dir .. "/Course/Course.php"
		vim.cmd("edit " .. filename)
		local bufnr = vim.api.nvim_get_current_buf()
		local client_id = vim.lsp.start({
			name = "phpactor",
			cmd = { "phpactor", "language-server", "-vvv" },
			root_dir = src_root_dir,
			capabilities = vim.lsp.protocol.make_client_capabilities(),
		})
		vim.lsp.buf_attach_client(bufnr, client_id)
		vim.wait(3000)

		local result = treesitter.parse_file({
			bufnr = bufnr,
		})

		local expected = {
			{
				col = 13,
				filename = src_root_dir .. "/Course/Course.php",
				kind = "Property",
				lnum = 14,
				text = "[Property] $att",
				visibility = "private",
			},
			{
				col = 21,
				filename = src_root_dir .. "/Course/Course.php",
				kind = "Function",
				lnum = 16,
				text = "[Function] __construct",
				visibility = "public",
			},
			{
				col = 54,
				filename = src_root_dir .. "/Course/Course.php",
				kind = "Property",
				lnum = 16,
				text = "[Property] $id",
				visibility = "private",
			},
			{
				col = 74,
				filename = src_root_dir .. "/Course/Course.php",
				kind = "Property",
				lnum = 16,
				text = "[Property] $name",
				visibility = "private",
			},
			{
				col = 104,
				filename = src_root_dir .. "/Course/Course.php",
				kind = "Property",
				lnum = 16,
				text = "[Property] $duration",
				visibility = "private",
			},
			{
				col = 21,
				filename = src_root_dir .. "/Course/Course.php",
				kind = "Function",
				lnum = 20,
				text = "[Function] foo",
				visibility = "public",
			},
			{
				col = 22,
				filename = src_root_dir .. "/Course/Course.php",
				kind = "Function",
				lnum = 24,
				text = "[Function] bar",
				visibility = "private",
			},
			{
				col = 21,
				filename = src_root_dir .. "/Course/Course.php",
				kind = "Function",
				lnum = 29,
				text = "[Function] fizz",
				visibility = "public",
			},
			{
				col = 27,
				filename = src_root_dir .. "/Shared/AggregateRoot.php",
				kind = "Function",
				lnum = 11,
				text = "[Function] AggregateRoot::pullDomainEvents",
				visibility = "public",
			},
			{
				col = 30,
				filename = src_root_dir .. "/Shared/AggregateRoot.php",
				kind = "Function",
				lnum = 19,
				text = "[Function] AggregateRoot::record",
				visibility = "protected",
			},
			{
				col = 21,
				filename = src_root_dir .. "/Shared/SomeTrait.php",
				kind = "Function",
				lnum = 8,
				text = "[Function] SomeTrait::publicTraitFunction",
				visibility = "public",
			},
			{
				col = 24,
				filename = src_root_dir .. "/Shared/SomeTrait.php",
				kind = "Function",
				lnum = 10,
				text = "[Function] SomeTrait::protectedTraitFunction",
				visibility = "protected",
			},
		}
		assert.are.same(result, expected)
	end)
end)

local treesitter = require("clapi.treesitter")
local t = require("plenary.async.tests")

t.describe("treesitter.parse_file", function()
	t.it("should parse methods from a PHP file", function()
		local src_root_dir = vim.fn.getcwd() .. "/tests/clapi/resources/code/php/php-ddd-example/src"
		local filename = src_root_dir .. "/Mooc/Courses/Domain/Course.php"
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
				col = 18,
				filename = src_root_dir .. "/Mooc/Courses/Domain/Course.php",
				kind = "Function",
				lnum = 12,
				text = "[Function] __construct",
				visibility = "public",
			},
			{
				col = 56,
				filename = src_root_dir .. "/Mooc/Courses/Domain/Course.php",
				kind = "Property",
				lnum = 12,
				text = "[Property] $id",
				visibility = "private",
			},
			{
				col = 80,
				filename = src_root_dir .. "/Mooc/Courses/Domain/Course.php",
				kind = "Property",
				lnum = 12,
				text = "[Property] $name",
				visibility = "private",
			},
			{
				col = 119,
				filename = src_root_dir .. "/Mooc/Courses/Domain/Course.php",
				kind = "Property",
				lnum = 12,
				text = "[Property] $duration",
				visibility = "private",
			},
			{
				col = 25,
				filename = src_root_dir .. "/Mooc/Courses/Domain/Course.php",
				kind = "Function",
				lnum = 14,
				text = "[Function] create",
				visibility = "public",
			},
			{
				col = 18,
				filename = src_root_dir .. "/Mooc/Courses/Domain/Course.php",
				kind = "Function",
				lnum = 23,
				text = "[Function] id",
				visibility = "public",
			},
			{
				col = 18,
				filename = src_root_dir .. "/Mooc/Courses/Domain/Course.php",
				kind = "Function",
				lnum = 28,
				text = "[Function] name",
				visibility = "public",
			},
			{
				col = 18,
				filename = src_root_dir .. "/Mooc/Courses/Domain/Course.php",
				kind = "Function",
				lnum = 33,
				text = "[Function] duration",
				visibility = "public",
			},
			{
				col = 18,
				filename = src_root_dir .. "/Mooc/Courses/Domain/Course.php",
				kind = "Function",
				lnum = 38,
				text = "[Function] rename",
				visibility = "public",
			},
			{
				col = 24,
				filename = src_root_dir .. "/Shared/Domain/Aggregate/AggregateRoot.php",
				kind = "Function",
				lnum = 13,
				text = "[Function] AggregateRoot::pullDomainEvents",
				visibility = "public",
			},
			{
				col = 27,
				filename = src_root_dir .. "/Shared/Domain/Aggregate/AggregateRoot.php",
				kind = "Function",
				lnum = 21,
				text = "[Function] AggregateRoot::record",
				visibility = "protected",
			},
		}
		assert.are.same(result, expected)
	end)
end)

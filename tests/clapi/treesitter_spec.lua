local treesitter = require("clapi.treesitter")
local async = require("plenary.async")
local t = require("plenary.async.tests")

local fn = function()
	async.run(function()
		local filename =
			"/home/markel/estudio/lua/clapi.nvim/tests/clapi/resources/code/php/php-ddd-example/src/Mooc/Courses/Domain/Course.php"
		vim.cmd("edit " .. filename)
		vim.lsp.start({
			name = "phpactor",
			cmd = { "phpactor", "language-server", "-vvv" },
			root_dir = vim.fs.dirname(
				vim.api.nvim_buf_get_name(0)
				-- '/home/markel/estudio/lua/clapi.nvim/tests/clapi/resources/code/php/php-ddd-example'
				-- vim.fs.find({ "composer.json", ".git" }, { upward = true })[1] or
			),
		})
		vim.lsp.buf_attach_client(0, 1)
		print("LSP attached:", vim.lsp.buf_is_attached(0, 1))
		print("LSP status:", vim.lsp.status())
		local result = treesitter.parse_file({
			bufnr = 0,
		})
		vim.print("r", result)
		assert(true == false)
	end)
	vim.print("aftertest")
	-- 	async.run(result, function()
	-- 		vim.print("y", result())
	-- 		assert(true == false)
	-- 	end)
end

-- vim.print(fn)

describe("treesitter.parse_file", function()
	it("should parse methods from a PHP file", fn)
end)

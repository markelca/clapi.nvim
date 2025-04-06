local treesitter = require("clapi.treesitter")
local async = require("plenary.async")
local t = require("plenary.async.tests")

local fn = function()
	async.run(function()
		local filename =
			"/home/markel/estudio/lua/clapi.nvim/tests/clapi/resources/code/php/php-ddd-example/src/Mooc/Courses/Domain/Course.php"
		vim.cmd("edit " .. filename)
		for c in ipairs(vim.lsp.get_clients()) do
			vim.print(c)
			vim.lsp.stop_client(c)
		end
		vim.lsp.start({
			name = "phpactor",
			cmd = { "phpactor", "language-server", "-vvv" },
			root_dir = "/home/markel/estudio/lua/clapi.nvim/tests/clapi/resources/code/php/php-ddd-example/src",
			capabilities = vim.lsp.protocol.make_client_capabilities(),
		})
		vim.lsp.buf_attach_client(0, 1)
		vim.print(vim.lsp.buf_request_sync(28, "workspace/symbol", { query = "AggregateRoot" }))
		print("LSP attached:", vim.lsp.buf_is_attached(0, 1))
		-- print("LSP status:", vim.lsp.status())
		-- local result = treesitter.parse_file({
		-- 	bufnr = 0,
		-- })
		-- vim.print("r", result)
		-- assert(true == false)
	end)
	vim.print("aftertest")
	-- 	async.run(result, function()
	-- 		vim.print("y", result())
	-- 		assert(true == false)
	-- 	end)
end

-- vim.print(fn)

describe("treesitter.parse_file", function()
	-- it("should parse methods from a PHP file", fn)
	it("async test", function()
		local co = coroutine.running()
		vim.defer_fn(function()
			coroutine.resume(co, "BAR")
		end, 1000)
		--The test will reach here immediately.
		local x = coroutine.yield()
		assert(x ~= nil)
		assert(x ~= "FOO")
		--The test will only reach here after one second, when the deferred function runs.
	end)
end)

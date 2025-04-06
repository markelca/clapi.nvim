local treesitter = require("clapi.treesitter")
local async = require("plenary.async")
local t = require("plenary.async.tests")

local fn = function()
	local filename =
		"/home/markel/estudio/lua/clapi.nvim/tests/clapi/resources/code/php/php-ddd-example/src/Mooc/Courses/Domain/Course.php"
	vim.cmd("edit " .. filename)
	local bufnr = vim.api.nvim_get_current_buf()
	local client_id = vim.lsp.start({
		name = "phpactor",
		cmd = { "phpactor", "language-server", "-vvv" },
		root_dir = "/home/markel/estudio/lua/clapi.nvim/tests/clapi/resources/code/php/php-ddd-example/src",
		capabilities = vim.lsp.protocol.make_client_capabilities(),
	})
	vim.lsp.buf_attach_client(bufnr, client_id)
	vim.wait(1000)
	vim.print(vim.lsp.buf_request_sync(bufnr, "workspace/symbol", { query = "AggregateRoot" }))
	-- print("LSP attached:", vim.lsp.buf_is_attached(0, 1))
	-- print("LSP status:", vim.lsp.status())
	-- local result = treesitter.parse_file({
	-- 	bufnr = bufnr,
	-- })
	-- vim.print("r", result)
	-- assert(true == false)
	vim.print("aftertest")
	-- 	async.run(result, function()
	-- 		vim.print("y", result())
	-- 		assert(true == false)
	-- 	end)
end

local function defer_test()
	vim.wait(1000, function()
		print("Defered func!")
	end)
	print("end test")
end

-- vim.print(fn)
local function async_test()
	local co = coroutine.running()
	vim.defer_fn(function()
		coroutine.resume(co, "BAR")
	end, 1000)
	--The test will reach here immediately.
	local x = coroutine.yield()
	assert(x ~= nil)
	assert(x ~= "FOO")
	--The test will only reach here after one second, when the deferred function runs.
end

local function lsp_test()
	local filename =
		"/home/markel/estudio/lua/clapi.nvim/tests/clapi/resources/code/php/php-ddd-example/src/Mooc/Courses/Domain/Course.php"

	-- Open the file and get the correct buffer number
	vim.cmd("edit " .. filename)
	local bufnr = vim.api.nvim_get_current_buf()
	vim.print("Buffer ID:", bufnr)

	-- Start the LSP client
	local client_id = vim.lsp.start({
		name = "phpactor",
		cmd = { "phpactor", "language-server", "-vvv" },
		root_dir = "/home/markel/estudio/lua/clapi.nvim/tests/clapi/resources/code/php/php-ddd-example/src",
		capabilities = vim.lsp.protocol.make_client_capabilities(),
	})
	vim.print("LSP ID:", client_id)

	-- Print buffer info for debugging
	vim.cmd("ls")
	vim.print("LSP attached:", vim.lsp.buf_is_attached(bufnr, client_id))
	vim.print("LSP clients:", vim.lsp.get_clients())

	-- Add a small delay to ensure the LSP has time to initialize and attach
	vim.wait(1000)
	vim.print("SNTHSNTHSNTH")
	print("LSP attached:", vim.lsp.buf_is_attached(bufnr, client_id))

	-- Only make the request if the client is attached
	if vim.lsp.buf_is_attached(bufnr, client_id) then
		local result = vim.lsp.buf_request_sync(bufnr, "workspace/symbol", { query = "AggregateRoot" }, 5000)
		vim.print("Result:", result)
	else
		print("LSP client not attached, skipping request")
	end
end

describe("treesitter.parse_file", function()
	it("should parse methods from a PHP file", fn)
	-- t.it("should parse methods from a PHP file", lsp_test)
	-- it("async test", async_test)
	-- it("defer test", defer_test)
end)

local treesitter = require("clapi.treesitter")
local async = require("plenary.async")
local t = require("plenary.async.tests")

local fn = function()
	require("nvim-treesitter.install").ensure_installed_sync("php")
	vim.wait(10000)
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

	-- vim.print("id", client_id)
	local result = treesitter.parse_file({
		bufnr = bufnr,
	})
	assert(result ~= nil)
end

local function defer_test()
	vim.wait(1000)
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
	print("LSP attached:", vim.lsp.buf_is_attached(bufnr, client_id))

	-- Only make the request if the client is attached
	if vim.lsp.buf_is_attached(bufnr, client_id) then
		vim.lsp.buf_request(
			bufnr,
			"workspace/symbol",
			{ query = "AggregateRoot" },
			function(err, result, context, config)
				vim.print("Result:", err, result)
			end
		)
		vim.wait(5000)
	else
		print("LSP client not attached, skipping request")
	end
end

t.describe("treesitter.parse_file", function()
	t.it("should parse methods from a PHP file", fn)
	-- t.it("should parse methods from a PHP file", lsp_test)
	-- it("async test", async_test)
	-- t.it("defer test", defer_test)
end)

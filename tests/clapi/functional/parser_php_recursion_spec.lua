local parser = require("clapi.parser.init")
local t = require("plenary.async.tests")

t.describe("parser.parse_file with recursive inheritance", function()
	t.it("should handle recursive inheritance without infinite loops", function()
		local src_root_dir = vim.fn.getcwd() .. "/tests/clapi/functional/resources/code/php/example/src"
		local filename = src_root_dir .. "/Course/Recursive.php"
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

		local result = parser.parse_file({
			bufnr = bufnr,
			show_inherited = true,
		})

		-- Test that we get results without hanging due to recursion
		assert.is_table(result)
		
		-- Verify the expected methods are found
		local found_get_subscribed_services = false
		local found_get_view_handler = false
		
		for _, item in ipairs(result) do
			if item.text == "[Function] getSubscribedServices" or 
			   item.text == "[Function] BaseAbstractFOSRestController::getSubscribedServices" then
				found_get_subscribed_services = true
			end
			if item.text == "[Function] getViewHandler" or 
			   item.text == "[Function] AbstractFOSRestController::getViewHandler" then
				found_get_view_handler = true
			end
		end
		
		assert.is_true(found_get_subscribed_services, "Should find getSubscribedServices method")
		assert.is_true(found_get_view_handler, "Should find getViewHandler method")
	end)
end)
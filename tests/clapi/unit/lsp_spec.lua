local lsp = require("clapi.lsp")
local utils = require("clapi.utils")
local t = require("plenary.async.tests")

-- Helper function to mock vim.lsp.buf_request
local function setup_lsp_mock(return_value, should_error)
	local original_buf_request = vim.lsp.buf_request
	vim.lsp.buf_request = function(_, _, _, callback)
		if should_error then
			callback("Error", nil, nil, nil)
		else
			callback(nil, return_value, nil, nil)
		end
	end
	return original_buf_request
end

t.describe("get_file_from_position", function()
	t.it("should return the file path from a valid position", function()
		-- Mock data
		local mock_return = {
			uri = "file:///path/to/definition.php",
		}

		-- Mock the LSP request
		local original_buf_request = setup_lsp_mock(mock_return, false)

		-- Mock utils.notify to catch any errors
		local original_notify = utils.notify
		local notify_called = false
		utils.notify = function(_, _)
			notify_called = true
		end

		-- Call the function
		local result = lsp.get_file_from_position({
			bufnr = 1,
			position = { line = 10, character = 15 },
		})

		-- Restore original functions
		vim.lsp.buf_request = original_buf_request
		utils.notify = original_notify

		-- Assertions
		assert(result == "/path/to/definition.php", "Should return the correct file path")
		assert(not notify_called, "No error should be reported")
	end)

	t.it("should handle array result format", function()
		-- Mock data (LSP response in array format)
		local mock_return = {
			{ uri = "file:///path/to/array/definition.php" },
		}

		-- Mock the LSP request
		local original_buf_request = setup_lsp_mock(mock_return, false)

		-- Call the function
		local result = lsp.get_file_from_position({
			bufnr = 1,
			position = { line = 10, character = 15 },
		})

		-- Restore original function
		vim.lsp.buf_request = original_buf_request

		-- Assertions
		assert(result == "/path/to/array/definition.php", "Should handle array result format")
	end)

	t.it("should handle targetUri format", function()
		-- Mock data (LSP response with targetUri)
		local mock_return = {
			{ targetUri = "file:///path/to/target/definition.php" },
		}

		-- Mock the LSP request
		local original_buf_request = setup_lsp_mock(mock_return, false)

		-- Call the function
		local result = lsp.get_file_from_position({
			bufnr = 1,
			position = { line = 10, character = 15 },
		})

		-- Restore original function
		vim.lsp.buf_request = original_buf_request

		-- Assertions
		assert(result == "/path/to/target/definition.php", "Should handle targetUri format")
	end)

	t.it("should handle errors from LSP request", function()
		-- Mock the LSP request to return an error
		local original_buf_request = setup_lsp_mock(nil, true)

		-- Mock utils.notify to catch the error
		local original_notify = utils.notify
		local notify_called = false
		local notify_level = nil

		utils.notify = function(_, opts)
			notify_called = true
			notify_level = opts.level
		end

		-- Call the function
		local result = lsp.get_file_from_position({
			bufnr = 1,
			position = { line = 10, character = 15 },
		})

		-- Restore original functions
		vim.lsp.buf_request = original_buf_request
		utils.notify = original_notify

		-- Assertions
		assert(result == nil, "Should return nil on error")
		assert(notify_called, "Error notification should be triggered")
		assert(notify_level == "ERROR", "Should notify with ERROR level")
	end)

	t.it("should handle missing position parameter", function()
		-- Mock utils.notify to catch the error
		local original_notify = utils.notify
		local notify_called = false
		local notify_level = nil
		local notify_message = nil

		utils.notify = function(_, opts)
			notify_called = true
			notify_level = opts.level
			notify_message = opts.msg
		end

		-- Call the function without position
		local result = lsp.get_file_from_position({
			bufnr = 1,
			-- position missing
		})

		-- Restore original function
		utils.notify = original_notify

		-- Assertions
		assert(result == nil, "Should return nil when position is missing")
		assert(notify_called, "Error notification should be triggered")
		assert(notify_level == "ERROR", "Should notify with ERROR level")
		assert(notify_message == "Position not provided", "Should notify with correct message")
	end)

	t.it("should prevent multiple callbacks", function()
		-- Create a mock that calls the callback multiple times
		local original_buf_request = vim.lsp.buf_request
		local warn_called = false

		-- Mock the LSP request
		vim.lsp.buf_request = function(_, _, _, callback)
			-- First call with valid result
			callback(nil, { uri = "file:///first/callback.php" }, nil, nil)

			-- Second call that should be ignored
			callback(nil, { uri = "file:///second/callback.php" }, nil, nil)
		end

		-- Mock utils.notify to detect warnings
		local original_notify = utils.notify
		utils.notify = function(src, opts)
			vim.print("custom utils called")
			if opts and opts.level == "WARN" then
				warn_called = true
			end
		end

		-- Call the function (works synchronously in tests)
		local result = lsp.get_file_from_position({
			bufnr = 1,
			position = { line = 10, character = 15 },
		})

		-- Restore original functions
		vim.lsp.buf_request = original_buf_request
		utils.notify = original_notify

		-- Assertions
		assert(result == "/first/callback.php", "Should return result from first callback only")
		-- TODO: fix
		-- assert(warn_called == true, "Warning should be logged for ignored callback")
	end)
end)

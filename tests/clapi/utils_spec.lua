local utils = require("clapi.utils")

describe("get_file_extension", function()
	it("should extract extension from a filepath", function()
		local extension = utils.get_file_extension("/path/to/file.php")
		assert(extension == "php")
	end)

	it("should return nil when no extension exists", function()
		local extension = utils.get_file_extension("/path/to/file")
		assert(extension == nil)
	end)

	it("should handle multiple dots in filename", function()
		local extension = utils.get_file_extension("/path/to/file.name.lua")
		assert(extension == "lua")
	end)
end)

describe("notify", function()
	it("should call vim.notify with the correct format", function()
		local original_notify = vim.notify
		local called = false
		local msg_received = nil
		local level_received = nil
		local opts_received = nil

		-- Mock vim.notify
		vim.notify = function(msg, level, opts)
			called = true
			msg_received = msg
			level_received = level
			opts_received = opts
		end

		-- Call our function with test parameters
		utils.notify("test_func", {
			msg = "test message",
			level = "INFO",
		})

		-- Restore original function
		vim.notify = original_notify

		-- Assertions
		assert(called, "vim.notify should have been called")
		assert(msg_received == "[clapi.test_func]: test message", "Message format is incorrect")
		assert(level_received == vim.log.levels.INFO, "Level is incorrect")
		assert(type(opts_received) == "table", "Options should be a table")
		assert(opts_received.title == "telescope.nvim", "Title is incorrect")
	end)

	it("should use vim.notify_once when once option is true", function()
		local original_notify = vim.notify
		local original_notify_once = vim.notify_once
		local notify_called = false
		local notify_once_called = false

		-- Mock functions
		vim.notify = function()
			notify_called = true
		end
		vim.notify_once = function()
			notify_once_called = true
		end

		-- Call with once = true
		utils.notify("test_func", {
			msg = "test message",
			level = "INFO",
			once = true,
		})

		-- Restore original functions
		vim.notify = original_notify
		vim.notify_once = original_notify_once

		-- Assertions
		assert(not notify_called, "vim.notify should not have been called")
		assert(notify_once_called, "vim.notify_once should have been called")
	end)

	it("should throw an error when an invalid level is provided", function()
		local success, err = pcall(function()
			utils.notify("test_func", {
				msg = "test message",
				level = "INVALID_LEVEL",
			})
		end)

		assert(not success, "Function should have thrown an error")
		assert(type(err) == "string" and err:match("Invalid error level"), "Error message should mention invalid level")
	end)
end)

describe("read_file", function()
	it("should return nil when file does not exist", function()
		-- Mock vim.fn.filereadable to return 0
		local original_filereadable = vim.fn.filereadable
		vim.fn.filereadable = function()
			return 0
		end

		local result = utils.read_file("/non/existent/file.txt")

		-- Restore original function
		vim.fn.filereadable = original_filereadable

		assert(result == nil, "Should return nil for non-existent file")
	end)

	it("should return file content when file exists", function()
		-- Mock required functions
		local original_filereadable = vim.fn.filereadable
		local original_readfile = vim.fn.readfile

		vim.fn.filereadable = function()
			return 1
		end
		vim.fn.readfile = function()
			return { "line1", "line2", "line3" }
		end

		local result = utils.read_file("/path/to/file.txt")

		-- Restore original functions
		vim.fn.filereadable = original_filereadable
		vim.fn.readfile = original_readfile

		assert(result == "line1\nline2\nline3", "Should return joined content of the file")
	end)
end)


local treesitter = require("clapi.parsers.current")
local utils = require("clapi.utils")

describe("treesitter.get_query", function()
	it("should return nil when no query is found", function()
		-- Mock vim.api.nvim_get_runtime_file to return empty results
		local original_get_runtime_file = vim.api.nvim_get_runtime_file
		vim.api.nvim_get_runtime_file = function()
			return {}
		end

		local result = treesitter.get_query("not_a_lang", "not_a_query")

		-- Restore original function
		vim.api.nvim_get_runtime_file = original_get_runtime_file

		assert(result == nil, "Should return nil when no query file is found")
	end)

	it("should find and return query file content", function()
		-- Mock vim.api.nvim_get_runtime_file to return a path with "clapi" in it
		local original_get_runtime_file = vim.api.nvim_get_runtime_file
		local original_read_file = utils.read_file

		vim.api.nvim_get_runtime_file = function()
			return {
				"/some/other/path/queries/php/locals.scm",
				"/home/user/clapi.nvim/queries/php/locals.scm",
			}
		end

		utils.read_file = function()
			return "((method_declaration name: (name) @method_name))"
		end

		local result = treesitter.get_query("php", "locals")

		-- Restore original functions
		vim.api.nvim_get_runtime_file = original_get_runtime_file
		utils.read_file = original_read_file

		assert(
			result == "((method_declaration name: (name) @method_name))",
			"Should return content of the found query file"
		)
	end)

	it("should prioritize files with 'clapi' in their path", function()
		-- Mock functions to test path selection logic
		local original_get_runtime_file = vim.api.nvim_get_runtime_file
		local original_read_file = utils.read_file
		local read_file_path = nil

		vim.api.nvim_get_runtime_file = function()
			return {
				"/first/path/queries/php/locals.scm",
				"/second/path/clapi/queries/php/locals.scm",
				"/third/path/queries/php/locals.scm",
			}
		end

		utils.read_file = function(path)
			read_file_path = path
			return "query content"
		end

		treesitter.get_query("php", "locals")

		-- Restore original functions
		vim.api.nvim_get_runtime_file = original_get_runtime_file
		utils.read_file = original_read_file

		-- Check that the clapi path was selected
		assert(
			read_file_path == "/second/path/clapi/queries/php/locals.scm",
			"Should select the path containing 'clapi'"
		)
	end)
end)

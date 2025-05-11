local make_entry = require("clapi.make_entry")

describe("gen_from_lsp_symbols", function()
	it("should generate entry maker function with visibility", function()
		-- Setup mock data
		local opts = {
			bufnr = 1,
		}

		-- Mock vim.api functions
		local original_get_current_buf = vim.api.nvim_get_current_buf
		local original_buf_get_name = vim.api.nvim_buf_get_name
		local original_buf_get_lines = vim.api.nvim_buf_get_lines

		vim.api.nvim_get_current_buf = function()
			return 1
		end
		vim.api.nvim_buf_get_name = function(bufnr)
			return "/path/to/test.php"
		end
		vim.api.nvim_buf_get_lines = function(bufnr, start, end_line, strict)
			return { "    public function testMethod() {" }
		end

		-- Create entry maker and test
		local entry_maker = make_entry.gen_from_lsp_symbols(opts)

		-- Create test entry
		local test_entry = {
			lnum = 10,
			col = 12,
			text = "[Function] testMethod",
			filename = "/path/to/test.php",
			visibility = "public",
		}

		-- Process the entry
		local result = entry_maker(test_entry)

		-- Assertions
		assert(result.visibility == "public", "Entry should preserve visibility")
		assert(result.symbol_type == "Function", "Symbol type should be extracted correctly")
		assert(result.symbol_name == "testMethod", "Symbol name should be extracted correctly")
		assert(result.ordinal:match("public"), "Ordinal should contain visibility")

		-- Restore original functions
		vim.api.nvim_get_current_buf = original_get_current_buf
		vim.api.nvim_buf_get_name = original_buf_get_name
		vim.api.nvim_buf_get_lines = original_buf_get_lines
	end)

	it("should handle entries without visibility", function()
		-- Setup mock data
		local opts = {
			bufnr = 1,
		}

		-- Mock vim.api functions
		local original_get_current_buf = vim.api.nvim_get_current_buf
		local original_buf_get_name = vim.api.nvim_buf_get_name

		vim.api.nvim_get_current_buf = function()
			return 1
		end
		vim.api.nvim_buf_get_name = function(bufnr)
			return "/path/to/test.php"
		end

		-- Create entry maker and test
		local entry_maker = make_entry.gen_from_lsp_symbols(opts)

		-- Create test entry without visibility
		local test_entry = {
			lnum = 15,
			col = 8,
			text = "[Variable] testVar",
			filename = "/path/to/test.php",
			-- No visibility specified
		}

		-- Process the entry
		local result = entry_maker(test_entry)

		-- Assertions
		assert(result.visibility == nil, "Entry should have nil visibility")
		assert(result.symbol_type == "Variable", "Symbol type should be extracted correctly")
		assert(result.symbol_name == "testVar", "Symbol name should be extracted correctly")

		-- Restore original functions
		vim.api.nvim_get_current_buf = original_get_current_buf
		vim.api.nvim_buf_get_name = original_buf_get_name
	end)

	it("should handle filename display correctly", function()
		-- Setup mock data
		local opts = {
			bufnr = 1,
		}

		-- Mock vim.api functions
		local original_get_current_buf = vim.api.nvim_get_current_buf
		local original_buf_get_name = vim.api.nvim_buf_get_name

		vim.api.nvim_get_current_buf = function()
			return 1
		end
		vim.api.nvim_buf_get_name = function(bufnr)
			return "/path/to/test.php"
		end

		-- Create entry maker and test
		local entry_maker = make_entry.gen_from_lsp_symbols(opts)

		-- Create test entry
		local test_entry = {
			lnum = 20,
			col = 10,
			text = "[Method] testMethod",
			filename = "/path/to/test.php",
			visibility = "protected",
		}

		-- Process the entry
		local result = entry_maker(test_entry)

		-- Assertions
		assert(result.ordinal:match("/path/to/test.php"), "Ordinal should include file path")
		assert(result.ordinal:match("protected"), "Ordinal should contain visibility")
		assert(result.ordinal:match("testMethod"), "Ordinal should contain symbol name")

		-- Restore original functions
		vim.api.nvim_get_current_buf = original_get_current_buf
		vim.api.nvim_buf_get_name = original_buf_get_name
	end)
end)


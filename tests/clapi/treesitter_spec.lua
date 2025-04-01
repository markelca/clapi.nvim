local treesitter = require("clapi.treesitter")
local async = require("plenary.async")

-- Helper function to convert regular function to async
local async_it = function(name, fn)
	it(
		name,
		async.void(function()
			fn()
		end)
	)
end

describe("treesitter.parse_file", function()
	local test_file = vim.fn.getcwd()
		.. "/tests/clapi/resources/code/php/php-ddd-example/src/Mooc/Courses/Domain/Course.php"

	async_it("should parse methods from a PHP file", function()
		local result = treesitter.parse_file({ filename = test_file })

		-- The file should have been parsed successfully
		assert.is_table(result)

		-- Extract just method names for easier verification
		local methods = {}
		for _, item in ipairs(result) do
			if item.kind == "Function" then
				-- Extract method name from text field - format is "[Function] Course::method_name"
				local method_name = item.text:match("%[Function%] Course::([^%(]+)")
				table.insert(methods, method_name)
			end
		end

		-- The file has create, id, name, duration, and rename methods
		assert.is_true(vim.tbl_contains(methods, "__construct"))
		assert.is_true(vim.tbl_contains(methods, "create"))
		assert.is_true(vim.tbl_contains(methods, "id"))
		assert.is_true(vim.tbl_contains(methods, "name"))
		assert.is_true(vim.tbl_contains(methods, "duration"))
		assert.is_true(vim.tbl_contains(methods, "rename"))
	end)

	async_it("should parse properties from a PHP file", function()
		local result = treesitter.parse_file({ filename = test_file })

		-- Extract just property names for easier verification
		local properties = {}
		for _, item in ipairs(result) do
			if item.kind == "Property" then
				-- Extract property name from text field - format is "[Property] Course::$property_name"
				local property_name = item.text:match("%[Property%] Course::(%$[%w_]+)")
				table.insert(properties, property_name)
			end
		end

		-- The class has $id, $name, and $duration properties
		assert.is_true(vim.tbl_contains(properties, "$id"))
		assert.is_true(vim.tbl_contains(properties, "$name"))
		assert.is_true(vim.tbl_contains(properties, "$duration"))
	end)

	async_it("should detect visibility modifiers correctly", function()
		local result = treesitter.parse_file({ filename = test_file })

		-- All methods should be public
		for _, item in ipairs(result) do
			if item.kind == "Function" then
				assert.equals("public", item.visibility)
			end
		end

		-- All properties should be private
		for _, item in ipairs(result) do
			if item.kind == "Property" then
				assert.equals("private", item.visibility)
			end
		end
	end)

	async_it("should include filename and line/column information", function()
		local result = treesitter.parse_file({ filename = test_file })

		for _, item in ipairs(result) do
			-- Each item should have filename and position data
			assert.equals(test_file, item.filename)
			assert.is_number(item.lnum)
			assert.is_number(item.col)
		end
	end)
end)

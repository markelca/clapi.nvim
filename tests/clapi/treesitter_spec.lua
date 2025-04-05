local treesitter = require("clapi.treesitter")
local async = require("plenary.async_lib")
local t = require("plenary.async_lib.tests")

local fn = function()
	vim.print("beforetest")
	local result = treesitter.parse_file({
		filename = "/home/markel/estudio/lua/clapi.nvim/tests/clapi/resources/code/php/php-ddd-example/src/Mooc/Courses/Domain/Course.php",
	})
	-- 	async.run(result, function()
	-- 		vim.print("y", result())
	-- 		assert(true == false)
	-- 	end)
end

-- vim.print(fn)

t.describe("treesitter.parse_file", function()
	t.it("should parse methods from a PHP file", fn)
end)

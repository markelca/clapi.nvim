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

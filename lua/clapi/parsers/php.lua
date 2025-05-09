local Parser = require("clapi.parsers")

local PhpParser = Parser:new()

function PhpParser.hi()
	print("Hi from php!")
end

return PhpParser

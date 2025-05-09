local Parser = require("clapi.parsers")

local p = Parser.get_parser("php")

if p then
	p:hi()
end

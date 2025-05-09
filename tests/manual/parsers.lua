local Parser = require("clapi.parsers")

local p = Parser.get_parser("java")

if p then
	p:hi()
end

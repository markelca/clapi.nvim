local Parser = require("clapi.parser.init")

local p = Parser.get_parser("java")

if p then
	p:hi()
end

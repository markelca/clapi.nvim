local utils = require("clapi.utils")

---@class Parser
local Parser = {}

function Parser:new(o)
	o = o or {} -- create object if user does not provide one
	setmetatable(o, self)
	self.__index = self
	return o
end

function Parser:hi()
	error("Not implemented!")
end

---@param lang string
---@return Parser|nil
function Parser.get_parser(lang)
	if not lang then
		utils.notify("Parser.fromLang", {
			level = "ERROR",
			msg = "Lang not provided",
		})
		return
	end

	local parsers = {
		["php"] = require("clapi.parsers.php"),
	}

	local parser = parsers[lang]

	if not parser then
		utils.notify("parsers.get_parser", {
			level = "ERROR",
			msg = "No parser available for language " .. lang,
		})
		return
	end

	return parser:new()
end

return Parser

local finder = require("clapi.finder")

---@class CLAPI
---@field builtin fun(opts?: table): nil
local M = {}

-- TODO: Unit test the whole plugin
M.builtin = finder.builtin

return M

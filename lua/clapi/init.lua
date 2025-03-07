local finder_v2 = require("clapi.finder_v2")
local finder = require("clapi.finder")

local M = {}

M.builtin = finder_v2.builtin
-- M.builtin = finder_lsp.builtin

return M

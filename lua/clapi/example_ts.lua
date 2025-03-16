local ts = require("clapi.treesitter")
local utils = require("clapi.utils")

-- vim.cmd.ls()

-- vim.print(vim.bo[x].filetype)
local r = ts.get_parent_file({ bufnr = 13 })
vim.print("anoteuh", r)

--
-- Load the treesitter parser for the language
-- ts.parse_file({ bufnr = 5 })
-- finder.builtin({ bufnr = 7 })

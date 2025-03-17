local ts = require("clapi.treesitter")
local utils = require("clapi.utils")

-- Function to get buffer ID of the second tab
function get_second_tab_buffer()
	-- Get all tabpages
	local tabpages = vim.api.nvim_list_tabpages()

	-- Check if there's at least a second tab
	if #tabpages < 2 then
		return nil, "No second tab exists"
	end

	-- Get the second tab (index 2)
	local second_tab = tabpages[2]

	-- If you want the tab with number 2 (not index 2)
	for _, tabpage in ipairs(tabpages) do
		if vim.api.nvim_tabpage_get_number(tabpage) == 2 then
			second_tab = tabpage
			break
		end
	end

	-- Get current window of the second tab
	local win = vim.api.nvim_tabpage_get_win(second_tab)

	-- Get buffer of the window
	local bufnr = vim.api.nvim_win_get_buf(win)

	return bufnr
end

-- Call the function and print the result
local buffer_id = get_second_tab_buffer()

-- vim.cmd.ls()

-- vim.print(vim.bo[x].filetype)
-- local r = ts.get_parent_file({ bufnr = 10 })
local r = ts.parse_file({ bufnr = buffer_id })
-- vim.print(r)
-- vim.print(r)

local utils = {}

--- Clapi Wrapper around vim.notify
---@param funname string: name of the function that will be
---@param opts table: opts.level string, opts.msg string, opts.once bool
function utils.notify(funname, opts)
	opts.once = vim.F.if_nil(opts.once, false)
	local level = vim.log.levels[opts.level]
	if not level then
		error("Invalid error level", 2)
	end
	local notify_fn = opts.once and vim.notify_once or vim.notify
	notify_fn(string.format("[clapi.%s]: %s", funname, opts.msg), level, {
		title = "telescope.nvim",
	})
end

function utils.read_file(path)
	-- Check if the file exists
	if vim.fn.filereadable(path) == 0 then
		return nil
	end

	-- Read the file into a table where each line is an element
	local lines = vim.fn.readfile(path)

	-- Join the lines with newline characters
	local content = table.concat(lines, "\n")
	return content
end
return utils

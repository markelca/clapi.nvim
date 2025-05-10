---@class Utils
local utils = {}

--- Clapi Wrapper around vim.notify
---@param funname string Name of the function that will be logged
---@param opts table Options for notification
---@param opts.level string The log level (ERROR, WARN, INFO, DEBUG, TRACE)
---@param opts.msg string The message to display
---@param opts.once? boolean Whether to only notify once, defaults to false
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

---Read file contents from a path
---@param path string The path to the file
---@return string|nil content The file content or nil if file doesn't exist
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

---Get the file extension from a filepath
---@param filepath string The path to the file
---@return string|nil extension The file extension or nil if not found
function utils.get_file_extension(filepath)
	-- Find the last dot position
	local lastDotIndex = filepath:match("^.+()%.%w+$")

	-- If a dot was found, return everything after it
	if lastDotIndex then
		return filepath:sub(lastDotIndex + 1)
	else
		return nil
	end
end

return utils

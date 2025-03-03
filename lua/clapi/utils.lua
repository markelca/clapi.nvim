local utils = {}

--- Clapi Wrapper around vim.notify
---@param funname string: name of the function that will be
---@param opts table: opts.level string, opts.msg string, opts.once bool
utils.notify = function(funname, opts)
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

return utils

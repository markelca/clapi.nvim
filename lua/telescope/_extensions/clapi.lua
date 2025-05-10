-- Register both as part of your extension
-- local x = require("clapi").builtin
local telescope = require("telescope")

local default_config = {
	show_inherited = true,
}

return telescope.register_extension({
	setup = function(ext_config)
		default_config = vim.tbl_deep_extend("force", default_config, ext_config or {})
	end,
	exports = {
		clapi = function()
			-- We copy the config to avoid polluting the extension default config between executions
			local config = vim.deepcopy(default_config)
			return require("clapi").builtin(config)
		end,
	},
})

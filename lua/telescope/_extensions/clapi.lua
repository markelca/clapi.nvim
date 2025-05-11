-- Register both as part of your extension
-- local x = require("clapi").builtin
local telescope = require("telescope")

local default_config = {
	show_inherited = true,
	visibility = nil, -- Default to showing all visibilities (public, protected, private)
}

return telescope.register_extension({
	setup = function(ext_config)
		default_config = vim.tbl_deep_extend("force", default_config, ext_config or {})
	end,
	exports = {
		clapi = function(opts)
			-- We copy the config to avoid polluting the extension default config between executions
			local config = vim.deepcopy(default_config)
			config = vim.tbl_deep_extend("force", config, opts or {})
			return require("clapi").builtin(config)
		end,
	},
})

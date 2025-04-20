-- Minimal init for running tests
vim.opt.runtimepath:append(vim.fn.getcwd())
vim.opt.runtimepath:append("~/estudio/lua/plenary.nvim")
vim.opt.runtimepath:append("~/.local/share/nvim/lazy/telescope.nvim")
vim.opt.runtimepath:append("~/.local/share/nvim/lazy/nvim-treesitter")
vim.opt.runtimepath:append("~/.local/share/nvim/lazy/mason.nvim")
vim.opt.runtimepath:append("~/.local/share/nvim/lazy/mason-lspconfig.nvim")

vim.opt.runtimepath:append("~/.local/share/nvim/lazy/mason-tool-installer.nvim")
vim.opt.runtimepath:append("~/.local/share/nvim/lazy/cmp-nvim-lsp")
vim.opt.runtimepath:append("~/.local/share/nvim/lazy/nvim-cmp")
vim.opt.runtimepath:append("~/.local/share/nvim/lazy/nvim-lspconfig")

require("nvim-treesitter.install").ensure_installed_sync("php")
-- Install parsers
require("cmp").setup({
	sources = {
		{ name = "nvim_lsp" },
	},
})

require("mason").setup({
	log_level = vim.log.levels.DEBUG, -- Enable detailed logs for debugging
	install_root_dir = vim.fn.expand("~/.local/share/nvim/mason"),
})

-- local lsp_list = { "phpactor", "java-language-server" }
local lsp_list = { "phpactor", "java-language-server" }

-- Force synchronous installation
local registry = require("mason-registry")
registry.refresh() -- Ensure the registry is up-to-date

for _, lsp in ipairs(lsp_list) do
	if not registry.is_installed(lsp) then
		-- print("Mason registry: Explicitly installing " .. lsp)

		-- Create a more robust installation process
		local pkg = registry.get_package(lsp)

		-- Install synchronously
		-- print("Installing " .. lsp .. " synchronously...")
		local handle = pkg:install()

		-- Set up installation status tracking
		local installation_complete = false

		handle:on("stderr", function(_, data)
			if data then
				-- Handle possible multi-line output
				for line in (data .. "\n"):gmatch("(.-)\n") do
					if line ~= "" then
						print(lsp .. " stderr: " .. line)
					end
				end
			end
		end)

		-- Wait for installation to complete with timeout
		local start_time = vim.loop.now()
		local timeout = 30000 -- 30 seconds

		while not installation_complete do
			vim.wait(1000) -- Check every second
			if (vim.loop.now() - start_time) > timeout then
				print("WARNING: Timed out waiting for " .. lsp .. " installation")
				break
			end
		end

		-- Verify installation
		if not registry.is_installed(lsp) then
			print("ERROR: " .. lsp .. " installation not detected after waiting")
		end
	end
end

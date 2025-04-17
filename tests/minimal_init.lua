-- Minimal init for running tests
vim.opt.runtimepath:append(vim.fn.getcwd())
-- vim.opt.runtimepath:append("~/.local/share/nvim/lazy/clapi.nvim")
-- vim.opt.runtimepath:append("~/.local/share/nvim/lazy/plenary.nvim")
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

-- Log directory information
vim.notify("Mason install root: " .. vim.fn.expand("~/.local/share/nvim/mason"))

-- Set up Mason-LSPConfig with explicit installation
require("mason-lspconfig").setup({
    ensure_installed = { "phpactor" },
})

-- Force synchronous installation with Mason Tool Installer
require("mason-tool-installer").setup({ 
    ensure_installed = { "phpactor" },
    auto_update = false,
    run_on_start = true,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

local servers = { "phpactor" }
require("mason-lspconfig").setup({
	handlers = {
		function(server_name)
			local server = servers[server_name] or {}
			require("lspconfig")[server_name].setup(server)
		end,
	},
})

-- NOTE: Had to add this to leave time for the gh action to download the treesitter php parser and LSP
vim.notify("Waiting for treesitter and LSP installation...")
vim.wait(20000) -- Increased wait time to 20 seconds
vim.notify("Checking Mason paths and installed servers...")
vim.api.nvim_exec("!ls -la ~/.local/share/nvim/mason/bin/", true)
vim.notify("Mason LSP installation paths: " .. vim.inspect(vim.fn.glob("~/.local/share/nvim/mason/packages/*", true, true)))

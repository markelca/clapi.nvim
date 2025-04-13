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

require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "phpactor" },
})

require("mason-tool-installer").setup({ ensure_installed = { "phpactor" } })

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

-- NOTE: Had to add this to leave time for the gh action to download the treesitter php parser
vim.wait(10000)

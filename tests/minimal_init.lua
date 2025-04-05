-- Minimal init for running tests
vim.opt.runtimepath:append(vim.fn.getcwd())
-- vim.opt.runtimepath:append("~/.local/share/nvim/lazy/clapi.nvim")
-- vim.opt.runtimepath:append("~/.local/share/nvim/lazy/plenary.nvim")
vim.opt.runtimepath:append("~/estudio/lua/plenary.nvim")
vim.opt.runtimepath:append("~/.local/share/nvim/lazy/telescope.nvim")
vim.opt.runtimepath:append("~/.local/share/nvim/lazy/nvim-treesitter")
vim.opt.runtimepath:append("~/.local/share/nvim/lazy/mason.nvim")
vim.opt.runtimepath:append("~/.local/share/nvim/lazy/mason-lspconfig.nvim")
-- Install parsers
require("nvim-treesitter.install").ensure_installed_sync("php")
require("mason").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "phpactor" },
})
vim.print(require("mason-lspconfig").get_installed_servers())

-- Minimal init for running tests
vim.opt.runtimepath:append(vim.fn.getcwd())
vim.opt.runtimepath:append("~/.local/share/nvim/lazy/clapi.nvim")
vim.opt.runtimepath:append("~/.local/share/nvim/lazy/plenary.nvim")
vim.opt.runtimepath:append("~/.local/share/nvim/lazy/telescope.nvim")
vim.opt.runtimepath:append("~/.local/share/nvim/lazy/nvim-treesitter")

vim.print(vim.api.nvim_list_runtime_paths())
-- Load the plugin
-- require("clapi")

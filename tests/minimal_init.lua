-- Minimal init for running tests
vim.cmd([[set runtimepath+=.]])
vim.cmd([[set runtimepath+=~/.local/share/nvim/lazy/clapi.nvim]])
vim.cmd([[set runtimepath+=~/.local/share/nvim/lazy/plenary.nvim]])
vim.cmd([[set runtimepath+=~/.local/share/nvim/lazy/telescope.nvim]])
vim.cmd([[set runtimepath+=~/.local/share/nvim/lazy/nvim-treesitter]])

-- Load the plugin
require("clapi")

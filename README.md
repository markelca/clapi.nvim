# clapi.nvim

The [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) pickers to show document symbols don't include the items' visibility modifiers. This extension provides a picker including them, so you can display and navigate the class/module interface easily.
![demo.gif](https://github.com/user-attachments/assets/6785bc10-faca-4ba6-81dd-ce7c5c79f039)

## Installation
Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
  'markelca/clapi.nvim',
  -- Dev Mode (Clone the repo, update the `dir` value and uncomment the two lines below)
  -- dir = '~/<dir-where-you-cloned>/clapi.nvim/',
  -- name = 'clapi',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-lua/plenary.nvim',
  },
  config = function()
    -- Enable the clapi extension adding the following line to your telescope configuration:
    pcall(require('telescope').load_extension 'clapi')

    -- Optionally you can set up a keymap to run the picker
    vim.keymap.set('n', '<leader>sa', require('clapi').builtin, { desc = '[S]earch [A]pi' })

    -- Configurations for the clapi picker
    require('telescope').setup {
      extensions = {
        clapi = {},
      },
    }
  end,
}
```
Full example in my nvim config repository: [nvim](https://github.com/MarkelCA/nvim/blob/master/lua/plugins/clapi.lua)
## Usage

After installation, you can use the picker with:

```vim
:Telescope clapi
```

Or in Lua:

```lua
:lua require('clapi').builtin()
```

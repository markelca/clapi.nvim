# clapi.nvim

The [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) pickers to show document symbols don't include the items' visibility modifiers. This extension provides a picker including them, so you can display and navigate the class/module interface easily.
![image](https://github.com/user-attachments/assets/f0de3756-5c90-45a1-8e6c-73a32471ab9d)

## Installation
Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{
  'markelca/clapi.nvim',
  -- Dev Mode (Uncomment the two lines below)
  -- dir = '~/estudio/lua/clapi.nvim/',
  -- name = 'clapi',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'nvim-treesitter/nvim-treesitter',
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

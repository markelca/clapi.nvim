# clapi.nvim

The [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) pickers to show document symbols don't include the items' visibility modifiers. This extension provides a picker including them, so you can display and navigate the class/module interface easily.
![image](https://github.com/user-attachments/assets/f0de3756-5c90-45a1-8e6c-73a32471ab9d)

## Installation

Using lazy.nvim:

```lua
{
    'nvim-telescope/telescope.nvim',
    dependencies = {
        'markelca/clapi.nvim',
    }
}
```

Enable the clapi extension adding the following line to your telescope configuration:
```lua
pcall(require('telescope').load_extension 'clapi')
```
Optionally you can set up a keymap to run the picker:
```lua
vim.keymap.set('n', '<leader>sa', require('clapi').builtin, { desc = '[S]earch [A]pi' })
```
Full example in my nvim config repository: [nvim](https://github.com/MarkelCA/nvim/blob/master/lua/plugins/telescope.lua)
## Usage

After installation, you can use the picker with:

```vim
:Telescope clapi
```

Or in Lua:

```lua
:lua require('clapi').builtin()
```

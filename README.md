# clapi.nvim

A telescope.nvim extension that reveals a module's public interface.
![image](https://github.com/user-attachments/assets/404c4c20-f14b-4359-b5e7-bcfeed389130)
🏗️ **Work In Progress**: The picture example shows hardcoded values, it's not fully implemented yet.

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

## Usage

After installation, you can use the picker with:

```vim
:Telescope clapi
```

Or in Lua:

```lua
:lua require('clapi').builtin()
```

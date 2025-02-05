# clapi.nvim

A telescope.nvim extension that reveals a module's public interface.

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

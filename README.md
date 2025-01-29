# Clapi

A custom picker extension for Telescope.nvim.

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

## Usage

After installation, you can use the picker with:

```vim
:Telescope custom_picker
```

Or in Lua:

```lua
require('telescope').extensions.custom_picker.custom_picker()
```

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
:Telescope clapi
```

Or in Lua:

```lua
require('telescope').extensions.clapi.clapi()
```

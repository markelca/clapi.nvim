# clapi.nvim

The [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) pickers to show document symbols don't include the items' visibility modifiers. This extension provides a picker including them, so you can display and navigate the class/module interface easily.

The plugin analyzes the entire class/module hierarchy, including parent classes, traits, interfaces, and other inherited elements, giving you a complete view of the API surface.
![demo.gif](https://github.com/user-attachments/assets/e9ddda56-912d-4475-b7d6-94c573939db6)

## Supported Languages

- PHP
- Java
- More languages coming soon! (Contributions welcome)

## Requirements

- [Neovim](https://neovim.io/) (0.7.0+)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim)

## Installation
Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
{ -- Add the clapi plugin with its dependencies
  'markelca/clapi.nvim',
  dependencies = {
    'nvim-telescope/telescope.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-lua/plenary.nvim',
  },
},
{ -- Add the following to your telescope configuration
  'nvim-telescope/telescope.nvim',
  config = function()
    require('telescope').setup {
      extensions = {
      -- Configurations for the clapi picker
        clapi = {
          show_inherited = true, -- Set to false to only show members defined in the current class
          default_visibility = "public", -- Filter by default visibility (public, protected, private)
        },
      },
    }
    -- Enable the clapi extension
    pcall(require('telescope').load_extension 'clapi')
    -- Optionally you can set up a keymap to run the picker
    vim.keymap.set('n', '<leader>sa', require('clapi').builtin, { desc = '[S]earch [A]pi' })
  end,
}
```
Full example in my [nvim](https://github.com/markelca/nvim) config repository: 
- [clapi](https://github.com/markelca/nvim/blob/master/lua/plugins/clapi.lua)
- [telescope](https://github.com/markelca/nvim/blob/master/lua/plugins/telescope.lua)

## Usage

After installation, you can use the picker with:

```vim
:Telescope clapi
```

Or in Lua:

```lua
:lua require('clapi').builtin()
```

You can also pass options to filter the results:

```lua
:lua require('clapi').builtin({show_inherited = false})
```

## Configuration Options

The following options can be configured in the telescope setup:

```lua
require('telescope').setup {
  extensions = {
    clapi = {
      -- Show inherited members (default: true)
      show_inherited = true,
      
      -- Default visibility filter (default: nil - show all)
      -- Can be "public", "protected", "private", or nil
      default_visibility = nil,
      
      -- Additional display customization options
      display = {
        show_filename = true,   -- Show filename in results
        show_line_numbers = true, -- Show line numbers
      },
    },
  },
}
```

## Troubleshooting

**Q: No symbols are displayed for my file**  
A: Make sure you have the appropriate language parser installed for treesitter:
```vim
:TSInstall php
:TSInstall java
```

**Q: Some inherited members are missing**  
A: The plugin requires proper parsing of the inheritance hierarchy. Ensure your project structure allows the plugin to find parent classes and interfaces.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Submit a pull request

For adding support for a new language, check the `lua/clapi/parser/` directory for examples.

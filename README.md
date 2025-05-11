# clapi.nvim

This is a Neovim plugin that analyzes the entire class/module hierarchy, including the document symbols of parent classes, traits, interfaces, and other inherited elements, giving you a complete view of the API surface.

**Why this project?**  
The [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) pickers to show document symbols don't include the items' visibility modifiers. This is a fundamental feature to reason about the interfaces you're exposing in order to design a well-architected codebase. Without visibility information, it's difficult to:

- Understand which methods and properties are part of the public API
- Identify protected members available to subclasses
- Distinguish between implementation details and interface contracts

clapi.nvim solves this by providing a complete picture of your class interface (or <ins>Cl</ins>ass <ins>API</ins>), making proper API design and navigation significantly easier.  

---

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
        clapi = {},
      },
    }
    -- Enable the clapi extension
    pcall(require('telescope').load_extension 'clapi')
    -- Optionally you can set up a keymap to run the picker
    vim.keymap.set('n', '<leader>sa', require('telescope').extensions.clapi.clapi, { desc = '[S]earch [A]pi' })
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
You can also add parameters
```vim
:Telescope clapi show_inherited=false visibility=public
```

Or in Lua:

```lua
-- Call the builtin directly
:lua require('clapi').builtin()
:lua require('clapi').builtin({show_inherited = false, visibility = 'public'}) -- You can pass options to filter the results

-- Call the extension instead. This option will use your default configurations from the telescope config
:lua require('telescope').extensions.clapi.clapi()
:lua require('telescope').extensions.clapi.clapi({show_inherited = false, visibility = 'public'}) -- You can also use parameters this way
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
      -- Examples: "public", "protected", "private"
      visibility = nil,
    },
  },
}
```

## Troubleshooting

**Q: No symbols are displayed for my file**  
- A: clapi needs treesitter in order to work. The language parsers should have been installed automatically, but make sure they are available:
```vim
:TSInstall php
:TSInstall java
```

**Q: Some inherited members are missing**  
- A: Check that you have an LSP installed and attached to the current buffer. It may take a few seconds since you open the file.
- A: The plugin requires proper parsing of the inheritance hierarchy. Ensure your project structure allows the LSP to find parent classes and interfaces.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Submit a pull request

For adding support for a new language, check the following folders for examples: 
- `lua/clapi/parser/`: Specific parser logic for each language.
- `queries/`: Treesitter queries for each language.

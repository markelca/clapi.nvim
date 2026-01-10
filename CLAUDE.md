# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

clapi.nvim is a Neovim plugin written in Lua that provides class/module API introspection with visibility modifiers. It extends telescope.nvim to show the complete class interface including visibility (public, protected, private) for methods, properties, and constants, including inherited members from parent classes, traits, and interfaces.

**Supported Languages:** PHP, Java

## Commands

### Running Tests

```bash
# Unit tests (no LSP required)
make test-unit

# Functional tests (requires LSP to be available)
make test-functional

# Run a single test file
nvim --headless -c "PlenaryBustedFile tests/clapi/unit/utils_spec.lua {minimal_init = 'tests/minimal_init.lua'}"
```

Tests use plenary.nvim's Busted framework. Unit tests are in `tests/clapi/unit/`, functional tests in `tests/clapi/functional/`.

## Architecture

### Core Data Flow

```
:Telescope clapi
    → finder.lua (creates telescope picker)
    → parser/init.lua (orchestrates parsing)
    → parser/__parser_*.lua (language-specific extraction)
    → lsp.lua (resolves parent class files for inheritance)
    → make_entry.lua (formats results with visibility column)
    → telescope picker display
```

### Key Modules

- **`lua/clapi/parser/init.lua`**: Main orchestrator. Calls treesitter to parse files, delegates to language-specific parsers, handles inheritance chain recursion via LSP.

- **`lua/clapi/parser/__parser.lua`**: Abstract base class defining the parser interface (`get_visibility`, `parse_method`, `parse_property`, `parse_constant`).

- **`lua/clapi/parser/__parser_php.lua` / `__parser_java.lua`**: Language-specific implementations. Extract visibility from AST nodes differently per language (PHP checks `visibility_modifier` child, Java parses `modifiers` node).

- **`lua/clapi/lsp.lua`**: Async LSP integration using plenary.async. Resolves parent class file paths via `textDocument/definition` requests.

- **`queries/{lang}/locals.scm`**: Treesitter queries capturing `method_name`, `prop_name`, `const_name` nodes.

- **`queries/{lang}/parent.scm`**: Treesitter queries capturing parent class/interface references.

### Adding a New Language

1. Create `lua/clapi/parser/__parser_{lang}.lua` implementing the Parser interface
2. Add treesitter queries in `queries/{lang}/locals.scm` and `queries/{lang}/parent.scm`
3. Add functional tests in `tests/clapi/functional/parser_{lang}_spec.lua`

## Dependencies

- telescope.nvim, nvim-treesitter, plenary.nvim (required)
- LSP server for the target language (required for inheritance resolution)

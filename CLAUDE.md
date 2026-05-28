# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A personal Neovim configuration written entirely in Lua, using lazy.nvim for plugin management. No VimScript. Targets Neovim 0.10+.

## No Build/Test Commands

This is a config repo — there is no build step, test runner, or linter. Changes take effect when Neovim is restarted or the file is `:source`d. To validate Lua syntax: `luacheck lua/` (if luacheck is installed).

## Architecture

### Entry Point

`init.lua` is the main entry point. It:
- Bootstraps lazy.nvim (auto-clones if missing)
- Sets `,` as the leader key
- Calls `require("lazy").setup("plugins")` which loads `lua/plugins/init.lua`
- Then loads core modules: `core.options`, `core.keymaps`, `user.autocommands`, `user.commands`, `object.setup()`, `watchers.direnv.setup()`
- Manages colorscheme (currently `base16-ayu-mirage`) with color caching

### Directory Layout

```
lua/
  core/           # Vim options, diagnostics, keymap dispatcher, auto-split resize
    keymaps/      # Modular keymaps: core/{buffers,git,movement,panes,quickfix,file_saving}.lua
                  # Plugin-specific: {lspsaga,neotest,dap,toggleterm,neogit,overseer,...}.lua
  lsp/            # LSP configuration
    setup.lua     # Central setup: iterates servers.lua, loads per-language configs
    servers.lua   # Maps language name → LSP server name
    go/, python/, lua/, javascript/, ruby/, java/, rust/, dart/, ...  # Per-language configs
  plugins/        # lazy.nvim plugin specs (one file per plugin or group)
  user/           # Custom modules: autocommands/, commands/, actions/, workspace_symbol_live
  object/         # OOP module system for quickfix/diagnostics with mutex logic
  utils/          # Shared utilities (keymap helpers, etc.)
  watchers/       # direnv integration (reloads env vars on directory change)
  overseer/       # Overseer task runner component configs
  monkey-patches/ # Runtime patches for plugins (currently avante.nvim)
  telescope/      # Custom Telescope extensions
ftplugin/         # Filetype-specific overrides (java.lua)
```

### LSP Architecture

`lsp/setup.lua` is the single entry point for all language servers. It:
1. Reads the language→server mapping from `lsp/servers.lua`
2. For each entry, requires `lsp/<lang>/config.lua` to get per-language settings
3. Calls `vim.lsp.config(server, merged_config)` and `vim.lsp.enable(server)`
4. Mason handles binary installation; lsp/setup.lua handles configuration

When adding a new language server:
- Add `lang = "server_name"` to `lsp/servers.lua`
- Create `lua/lsp/<lang>/config.lua` returning a config table (root_dir, settings, on_attach, etc.)

LSP is excluded for these buffer types: markdown, text, gitcommit, notify, toggleterm, noice, TelescopeResults, OverseerOutput, neo-tree, lazy.

### Plugin System

`lua/plugins/init.lua` returns a list of `require("plugins.<name>")` calls. Each `lua/plugins/<name>.lua` returns a lazy.nvim spec table. Plugin-specific keymaps live in `lua/core/keymaps/<plugin-name>.lua`, loaded by the keymap dispatcher.

### Keymap Convention

- Leader: `,`
- Core keymaps always loaded; LSP keymaps loaded on `LspAttach`
- `utils/keymap.lua` provides `map_for_all_and_terminal()` for maps that also work in terminal buffers
- Keymaps are organized by feature, not by key binding

### Notable Custom Modules

- **`user/workspace_symbol_live`** — custom live workspace symbol search (Telescope-like)
- **`object/`** — OOP wrappers around quickfix and diagnostics with mutual exclusion
- **`watchers/direnv.lua`** — reloads `.envrc` changes automatically into Neovim's environment
- **`overseer/`** — loads project-local `.nvim.lua` as Overseer task templates

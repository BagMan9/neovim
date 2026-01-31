# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a sophisticated Neovim IDE configuration (~66 Lua files, 10k+ LOC) built with a custom lazy loader (**lzl**) and Nix for reproducible, declarative plugin management. The configuration is distributed as a Home Manager module via flake.nix.

## Architecture

### Core Components

```
~/.config/nvim/
├── flake.nix              - Nix flake + Home Manager module
├── lua/
│   ├── my/                - Core configuration (options, autocmds, utils)
│   ├── plugins/           - Plugin specifications (~40 files by category)
│   ├── lzl/               - Custom lazy loader with npins integration
│   ├── cfg/               - Language-specific settings
│   └── keymaps.lua        - Global keybindings
├── nix/lzl-plugins.nix    - Builds plugins from npins + metadata
└── npins/                 - Pinned dependencies (sources.json, plugins.json)
```

### Plugin Loading System: lzl

**lzl** is a custom lazy loader that replaces lazy.nvim with Nix-aware plugin management:

**Plugin Flow:**
```
lua specs → :LzlExport → npins sync → plugins.json → Nix build → runtime
```

**Key Files:**
- `lua/lzl/lzl_loader.lua` - Main loader dispatch
- `lua/lzl/lzl_handler/` - Lazy-loading triggers (keys, cmd, event, ft)
- `lua/lzl/export.lua` - Syncs sources to npins, generates metadata
- `lua/lzl/source.lua` - GitHub/GitLab/Git repository abstraction
- `nix/lzl-plugins.nix` - Builds plugins from npins using plugins.json metadata

**Load Phases:**
1. **Startup** - treesitter, lz-n (required for bootstrap)
2. **LazyFile** - LSP, formatting, core language tools
3. **InsertEnter** - Completion (blink.cmp with dependencies)
4. **VeryLazy** - UI enhancements, optional features
5. **On-demand** - Git, search, motion plugins via event/cmd/key triggers

### Entry Points

- **`flake.nix`** - Home Manager module, Nix dependencies, mnw wrapper config
- **`lua/my/init.lua`** - Initializes utils, lzl loader, options, autocmds
- **`lua/keymaps.lua`** - Global keybindings (233 lines)

### Module Organization

**Plugins by Category** (in `lua/plugins/`):
- `ui/` - Statusline, colors, noice, fidget, dashboard
- `lang/` - LSP, formatting (conform.nvim), linting (nvim-lint)
- `editing` - Surround, autopairs, comments, mini.ai
- `git` - Gitsigns, fugitive, diffview
- `search` - Telescope, flash.nvim
- `motion` - Leap, flit, vim-matchup
- `cmp` - blink.cmp, snippets (luasnip)
- `treesitter` - Treesitter configs, textobjects
- `ai` - Avante, codecompanion
- `debug` - nvim-dap, dap-ui, dap-python, dap-virtual-text

**Utilities** (in `lua/my/utils/`):
- `lsp.lua` - LSP helpers (dynamic capabilities, on_attach)
- `format.lua` - Formatting utilities
- `defer.lua` - Deferred loading helpers
- `init.lua` - Error handling, metatable-based auto-loading

## Common Development Tasks

### Adding a New Plugin

1. **Create/edit plugin spec** in `lua/plugins/<category>/<plugin>.lua`:

```lua
{
  "plugin-name",
  source = {
    type = "github",
    owner = "author",
    repo = "plugin-name",
    branch = "main",  -- optional
  },
  build = {
    useNixpkgs = "plugin-name",  -- if using nixpkgs derivation
    nvimSkipModules = { "module.to.skip" },  -- for build issues
    nixDeps = { "telescope-nvim" },  -- Nix plugin dependencies
  },
  extraPackages = { "binary", "tool" },  -- runtime dependencies
  event = "LazyFile",  -- or cmd/keys/ft
  opts = { ... },
  after = function(plugin, opts)
    -- Setup function
  end,
}
```

2. **Export to npins**:
```vim
:LzlExport      " Sync sources to npins, write plugins.json
:LzlExport!     " Dry-run (preview changes)
```

3. **Rebuild Neovim** (if using Nix):
```bash
nix flake update
home-manager switch  # or your rebuild command
```

### Plugin Spec Patterns

#### For `build`

**Use `useNixpkgs` for:**
- Plugins with native Lua modules (blink.cmp, telescope-fzf-native)
- Complex build requirements
- Battle-tested nixpkgs derivations

**Use `nvimSkipModules` for:**
- Circular dependencies between plugins
- Modules that fail to load at build time
- Optional integrations you don't use

**Use `extraPackages` for:**
- Runtime binaries the plugin shell's out to
- LSP servers, formatters, linters
- Any external tool the plugin requires

### LSP Configuration

LSP setup is done via language specific files with nvim-lspconfig `opts`, which are combined & used via logic in `lua/plugins/lang/init.lua`:


**LSP keymaps** defined in `lua/my/intellisense.lua`:
- `gd` - Go to definition (telescope fallback)
- `gr` - References
- `gI` - Implementation
- `<leader>ca` - Code actions
- `<leader>cr` - Rename
- etc.

### Formatting and Linting

**Formatters** (conform.nvim in `lua/plugins/lang/init.lua`):
- Organized by filetype
- Auto-format on BufWritePre
- LSP fallback if no formatter configured

**Linters** (nvim-lint):
- Triggered on BufEnter, BufWritePost, InsertLeave
- Debounced execution (100ms)
- Per-filetype configuration

### Working with Nix

**Dev mode** (for rapid plugin iteration):
```nix
# In flake.nix, enable devMode in mnw config
devMode = true;  # Allows plugin edits without rebuild
```

**Platform-specific dependencies:**
- macOS: xcode-build-server, imagemagick, tuist
- All platforms: LSP servers, formatters, linters in flake.nix

**Updating dependencies:**
```bash
npins update <source-name>  # Update specific pin
nix flake update            # Update flake inputs
```

## Key Architectural Patterns

### LZL

LZL uses the same pattern as lazy.nvim - in fact, most of the logic is directly copied from there, just stripped of most other, non-direct plugin management features

#### Metatable-Based Auto-Loading

The `MyVim` module (`lua/my/init.lua`) uses metatables to lazy-load submodules:

```lua
setmetatable(M, {
  __index = function(t, k)
    t[k] = require("my." .. k)
    return t[k]
  end,
})
-- MyVim.lsp auto-loads lua/my/intellisense.lua
```

#### Event Triggers

- **LazyFile**: Custom event for file buffers (BufReadPost/BufNewFile/BufWritePre)
- **VeryLazy**: Delayed load for UI/optional features
- **InsertEnter**: Completion and snippet plugins
- **Filetype**: Language-specific tools (e.g., vimtex for tex)

#### Error Isolation

Plugins wrapped in pcall to prevent cascade failures:
```lua
local ok, result = pcall(require, "plugin")
if not ok then
  Utils.error("Failed to load plugin: " .. result)
  return
end
```

## Important Notes

### When Modifying Core Files

- **`lua/my/options.lua`** - Vim options (folding, clipboard, statusline)
- **`lua/my/autocmds.lua`** - Autocommands (don't break LazyFile event)
- **`lua/lzl/`** - Plugin loader internals (test thoroughly, affects all plugins)

### When Modifying flake.nix

- Keep Home Manager module interface stable
- Platform detection: `isMac = pkgs.stdenv.hostPlatform.isDarwin`
- Use `macList` helper for Darwin-only packages
- extraBinPath for runtime dependencies

### Plugin Spec Guidelines

- Use `event = "LazyFile"` for most not-immediately needed plugins
- Use `cmd` for command-triggered plugins (keeps startup fast)
- Use `keys` for keybinding-triggered plugins
- Dependencies auto-load before the plugin

### Nix Build Gotchas

- `nvimSkipModules` prevents module load during build (for circular deps)
- `useNixpkgs` bypasses custom build, uses nixpkgs derivation
- `extraPackages` goes into PATH, not plugin dependencies
- npins must be synced before Nix build (`:LzlExport`)

## Testing Changes

Since this is a Neovim config (not a plugin), there are no automated tests. Manual testing workflow:

1. Edit plugin spec or config file
2. Run `:LzlExport` if you modified sources
3. Reload Neovim or `:source` the file
4. Test the affected functionality
5. Check `:messages` for errors

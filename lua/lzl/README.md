# lzl - Lazy Loader for Neovim

A minimal plugin loader inspired by lazy.nvim with npins integration for Nix-based plugin management.

## Plugin Spec Format

### Basic (nixpkgs fallback)

For plugins available in nixpkgs, just use the name:

```lua
{
  "telescope.nvim",
  cmd = "Telescope",
  -- No source = uses pkgs.vimPlugins.telescope-nvim
}
```

### With Source (npins-managed)

For plugins not in nixpkgs or when you want version control:

```lua
{
  "octo.nvim",
  source = {
    type = "github",
    owner = "pwntester",
    repo = "octo.nvim",
    branch = "main",  -- optional
    rev = "abc123",   -- optional, pin to specific commit
  },
  cmd = "Octo",
  extraPackages = { "gh" },  -- runtime executables needed
}
```

### With Build Hints

For plugins that need special Nix build configuration:

```lua
{
  "xcodebuild.nvim",
  source = {
    type = "github",
    owner = "wojciech-kulik",
    repo = "xcodebuild.nvim",
  },
  build = {
    nvimSkipModules = {
      "xcodebuild.ui.pickers",
      "xcodebuild.dap",
    },
    nixDeps = { "telescope-nvim", "nui-nvim", "nvim-dap" },
  },
  ft = { "swift", "objc" },
}
```

### Using nixpkgs for Complex Plugins

For plugins with native Lua modules or complex builds (like `blink.cmp`),
use the nixpkgs derivation while still tracking the source:

```lua
{
  "blink.cmp",
  source = {
    type = "github",
    owner = "Saghen",
    repo = "blink.cmp",
  },
  build = {
    useNixpkgs = "blink-cmp",  -- use pkgs.vimPlugins.blink-cmp
  },
  event = "InsertEnter",
}
```

This gives you:
- Source tracking in npins (see when upstream updates)
- Battle-tested nixpkgs derivation (handles native builds correctly)
- No need to write custom derivations

### Pure nixpkgs Reference (no source tracking)

For plugins where you just want nixpkgs with some extra metadata:

```lua
{
  "blink.cmp",
  build = {
    useNixpkgs = "blink-cmp",  -- use pkgs.vimPlugins.blink-cmp
  },
  extraPackages = { "some-binary" },  -- still gets exported
  event = "InsertEnter",
}
```

No `source` field = no npins tracking, but `extraPackages` and other
metadata still gets written to `plugins.json`.

## Source Types

### GitHub

```lua
source = {
  type = "github",
  owner = "username",
  repo = "repo-name",
  branch = "main",     -- optional, defaults to default branch
  rev = "commit-sha",  -- optional, pin to specific commit
}
```

### GitLab

```lua
source = {
  type = "gitlab",
  owner = "username",
  repo = "repo-name",
  branch = "main",
}
```

### Git (any URL)

```lua
source = {
  type = "git",
  url = "https://git.example.com/repo.git",
  branch = "main",
}
```

## Export Command

After adding sources to your plugin specs:

```vim
:LzlExport      " Sync sources to npins and write plugins.json
:LzlExport!     " Dry-run mode (shows what would happen)
```

This will:
1. Initialize npins in `~/.config/nvim/npins/` if needed
2. Run `npins add` for any new plugin sources
3. Write `plugins.json` with build metadata

## Nix Integration

Import the generated plugins in your flake:

```nix
let
  lzlPlugins = import ./nix/lzl-plugins.nix {
    inherit pkgs;
    npinsDir = ./npins;
  };
in {
  # Use lzlPlugins.plugins - attrset of built vim plugins
  # Use lzlPlugins.extraPackages - list of runtime dependencies
  # Use lzlPlugins.pluginList - list of all plugin derivations
}
```

## Configuration

Configure export paths in lzl setup:

```lua
require("lzl").lzl_setup({
  spec = { import = "plugins" },
  export = {
    npins_dir = vim.fn.stdpath("config") .. "/npins",
    plugins_json = vim.fn.stdpath("config") .. "/npins/plugins.json",
  },
})
```

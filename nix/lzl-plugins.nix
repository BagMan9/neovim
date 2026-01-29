# lzl-plugins.nix
# Builds vim plugins from npins sources using metadata from plugins.json
#
# Usage in flake.nix:
#   let
#     lzlPlugins = import ./nix/lzl-plugins.nix {
#       inherit pkgs;
#       npinsDir = ./npins;
#     };
#   in
#   # lzlPlugins.plugins - attrset of built vim plugins
#   # lzlPlugins.extraPackages - list of all extraPackages across plugins
#
{ pkgs, npinsDir }:

let
  # Import npins sources
  sources = import npinsDir;

  # Read and parse plugins.json
  pluginsJsonPath = npinsDir + "/plugins.json";
  pluginsJson =
    if builtins.pathExists pluginsJsonPath then
      builtins.fromJSON (builtins.readFile pluginsJsonPath)
    else
      { };

  # Build a single vim plugin from npins source + metadata
  # If useNixpkgs is set, use the nixpkgs derivation instead of building from source
  mkPlugin =
    name: src:
    let
      meta = pluginsJson.${name} or { };
      lzlName = meta.lzl_name or name;
      useNixpkgs = meta.useNixpkgs or null;

      # If useNixpkgs is specified, use that package from pkgs.vimPlugins
      nixpkgPlugin = if useNixpkgs != null then pkgs.vimPlugins.${useNixpkgs} or null else null;

      # Build options from metadata
      skipModules = meta.nvimSkipModules or [ ];

      # Handle nix plugin dependencies
      # These should be names that exist in pkgs.vimPlugins
      nixDeps = map (depName: pkgs.vimPlugins.${depName} or null) (meta.nixDeps or [ ]);
      validDeps = builtins.filter (d: d != null) nixDeps;

      # Build from source
      builtPlugin = pkgs.vimUtils.buildVimPlugin (
        {
          pname = lzlName;
          version = src.revision or "git";
          src = src;
        }
        // (if skipModules != [ ] then { nvimSkipModules = skipModules; } else { })
        // (if validDeps != [ ] then { dependencies = validDeps; } else { })
      );
    in
    # Prefer nixpkgs derivation if useNixpkgs is set and package exists
    if nixpkgPlugin != null then
      nixpkgPlugin
    else if useNixpkgs != null then
      builtins.trace "Warning: useNixpkgs='${useNixpkgs}' not found in pkgs.vimPlugins, building from source" builtPlugin
    else
      builtPlugin;

  # Build all plugins from plugins.json
  # - If in npins sources: build from source (or use nixpkgs if useNixpkgs set)
  # - If NOT in sources but useNixpkgs set: use nixpkgs directly
  # - If NOT in sources and no useNixpkgs: skip (error in config)
  pluginNames = builtins.attrNames pluginsJson;

  mkPluginEntry =
    name:
    let
      meta = pluginsJson.${name} or { };
      useNixpkgs = meta.useNixpkgs or null;
      hasSource = sources ? ${name};
      nixpkgPlugin = if useNixpkgs != null then pkgs.vimPlugins.${useNixpkgs} or null else null;
    in
    if hasSource then
      # Has npins source - build (or use nixpkgs if specified)
      {
        inherit name;
        value = mkPlugin name sources.${name};
      }
    else if nixpkgPlugin != null then
      # No source but useNixpkgs specified and found
      {
        inherit name;
        value = nixpkgPlugin;
      }
    else if useNixpkgs != null then
      # useNixpkgs specified but not found
      builtins.trace "Warning: ${name} has useNixpkgs='${useNixpkgs}' but package not found and no source"
        null
    else
      # No source and no useNixpkgs - skip silently (might be intentionally nixpkgs-only)
      null;

  plugins = builtins.listToAttrs (builtins.filter (x: x != null) (map mkPluginEntry pluginNames));

  # Collect all extraPackages across all plugins
  allExtraPackages = builtins.concatLists (
    map (name: (pluginsJson.${name}.extraPackages or [ ])) pluginNames
  );

  # Resolve extraPackages names to actual packages
  # Assumes they're available in pkgs directly
  resolvePackage =
    name:
    let
      # Handle dotted paths like "python3Packages.debugpy"
      # builtins.split returns both parts and separator matches (as lists), so filter to strings only
      parts = builtins.filter builtins.isString (builtins.split "\\." name);
      resolved = builtins.foldl' (acc: part: acc.${part} or null) pkgs parts;
    in
    if resolved != null then resolved else builtins.trace "Warning: package '${name}' not found" null;

  extraPackages = builtins.filter (p: p != null) (map resolvePackage allExtraPackages);

in
{
  inherit plugins extraPackages;

  # Convenience: list of all plugin derivations
  pluginList = builtins.attrValues plugins;

  # For debugging: the raw metadata
  meta = pluginsJson;
}

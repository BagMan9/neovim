{
  description = "Isaac's Neovim configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    mnw.url = "github:Gerg-L/mnw";

    my_stdlib = {
      url = "path:/Users/isaac/Dev/my_stdlib"; # Will change to git URL later
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xcode-build-server = {
      url = "path:/Users/isaac/Dev/xcode-build-server"; # Will change to git URL later
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      mnw,
      my_stdlib,
      xcode-build-server,
    }:
    let
      # Shared base used by both the standalone package and the home-manager module.
      # Returns the discrete pieces of an mnw config so each call site can stitch
      # them into the slightly different surrounding shape it needs.
      mkShared =
        {
          pkgs,
          lib,
          latex ? false,
        }:
        let
          isMac = pkgs.stdenv.hostPlatform.isDarwin;
          macList = xs: lib.lists.optionals isMac xs;

          lzl-plugins = import ./nix/lzl-plugins.nix {
            inherit pkgs;
            npinsDir = ./npins;
          };

          xcodebuild-src = pkgs.fetchFromGitHub {
            owner = "wojciech-kulik";
            repo = "xcodebuild.nvim";
            rev = "0e6e3058a44622866219151209943a2120be66b5";
            hash = "sha256-9VSj5vKKUIUEHsh8MrLjqCAOtf+0a10pDikzOSNTtbs=";
          };

          xcodebuild-nvim = pkgs.vimUtils.buildVimPlugin {
            pname = "xcodebuild.nvim";
            version = "2025-07-02";
            src = xcodebuild-src;
            nvimSkipModules = [
              "xcodebuild.ui.pickers"
              "xcodebuild.actions"
              "xcodebuild.project.manager"
              "xcodebuild.project.assets"
              "xcodebuild.integrations.xcode-build-server"
              "xcodebuild.integrations.dap"
              "xcodebuild.code_coverage.report"
              "xcodebuild.dap"
            ];
            dependencies = with pkgs.vimPlugins; [
              telescope-nvim
              nui-nvim
              nvim-dap
            ];
          };

          # Plugins not (currently) controlled by lzl. lzl-plugins.pluginList is
          # appended below — anything in npins/plugins.json must NOT appear here
          # or it would be injected twice. nvim-treesitter itself stays here
          # intentionally (lzl can't manage its build).
          flakeOnlyPlugins = with pkgs.vimPlugins; [
            # nvim-notify
            # telescope-fzf-native-nvim
            # vim-illuminate
          ];
        in
        {
          inherit
            isMac
            macList
            lzl-plugins
            xcodebuild-src
            xcodebuild-nvim
            ;

          pluginsStart = [
            pkgs.vimPlugins.nvim-treesitter.withAllGrammars
          ];

          pluginsOpt =
            flakeOnlyPlugins
            ++ lzl-plugins.pluginList
            ++ macList [ xcodebuild-nvim ]
            ++ lib.lists.optionals latex [ pkgs.vimPlugins.vimtex ];

          extraBinPath =
            with pkgs;
            [
              ripgrep
              fd
              lldb
              jq
            ]
            ++ lzl-plugins.extraPackages
            ++ lib.lists.optionals latex [
              texlab
              texliveFull
              ghostscript_headless
            ]
            ++ macList (
              with pkgs;
              [
                imagemagick
                coreutils
              ]
            );

          providers.python3 = {
            enable = true;
            extraPackages = ps: [ ps.debugpy ];
          };
        };

      # Home-manager module (system-independent definition)
      homeManagerModule =
        {
          config,
          lib,
          pkgs,
          ...
        }:
        let
          cfg = config.programs.neovim-ide;

          shared = mkShared {
            inherit pkgs lib;
            latex = cfg.latex;
          };

          remote-debugger = pkgs.writeShellScriptBin "remote_debugger" (
            builtins.readFile "${shared.xcodebuild-src}/tools/remote_debugger"
          );

          # External packages from inputs
          xcode-build-server-pkg = xcode-build-server.packages.${pkgs.system}.xcode-build or null;

          # Safe neovim-unwrapped with fixed meta
          safe-neovim-unwrapped = pkgs.neovim-unwrapped.overrideAttrs (old: {
            meta = old.meta // {
              description = "neovim unwrapped";
              longDescription = old.meta.longDescription or "";
            };
          });

          mkLuaAttrs =
            attrs:
            let
              convertone =
                n: v:
                let
                  safe_lua = builtins.replaceStrings [ "-" ] [ "_" ] n;
                in
                "${safe_lua} = ${v}";

              merge = ls: lib.strings.concatStringsSep ",\n" ls;
            in
            merge (lib.attrsets.mapAttrsToList convertone attrs);

          # Create a renamed dev neovim package (nvim-dev binary)
          mkDevNeovim =
            basePkg:
            pkgs.runCommand "nvim-dev" { } ''
              mkdir -p $out/bin
              ln -s ${basePkg.devMode}/bin/nvim $out/bin/nvim-dev
            '';

          mkMnwConfig = {
            enable = true;
            neovim = safe-neovim-unwrapped;

            plugins.dev.myconf = {
              pure = ./.;
              impure = "${config.xdg.configHome}/nvim";
            };

            initLua =
              lib.mkOverride 5 # lua
                ''
                  _G.NIXATTRS = {
                    ${mkLuaAttrs cfg.globalAttrs}
                  }
                  ${if (cfg.luaconf != "") then ''require("${cfg.luaconf}")'' else ""}

                  ${if (cfg.mnw.initLua != "") then "${cfg.mnw.initLua}" else ""}
                '';

            plugins.start = shared.pluginsStart;
            plugins.opt = shared.pluginsOpt;
            extraBinPath = shared.extraBinPath;
            providers = shared.providers;
          };

        in
        {

          imports = [ mnw.homeManagerModules.mnw ];
          options.programs.neovim-ide = {
            enable = lib.mkEnableOption "Enable Neovim IDE";

            latex = lib.mkEnableOption "Enable LaTeX support";

            mnw = lib.mkOption {
              type = lib.types.attrs;
              default = { };
              description = "Additional mnw configuration to merge (e.g., initLua)";
            };

            dev = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Enable dev mode (impure plugin path)";
            };

            luaconf = lib.mkOption {
              type = lib.types.singleLineStr;
              default = "";
              description = "Your top-level config to require";
            };

            globalAttrs = lib.mkOption {
              type = lib.types.attrs;
              default = { };
              description = "Attributes to be made available in a NIXATTRS global variable";
            };
          };

          config = lib.mkIf cfg.enable {

            programs.mnw = lib.mkMerge [
              mkMnwConfig
              cfg.mnw
            ];

            # XDG data symlinks for the lazy loader
            xdg.dataFile = {
              start = {
                enable = true;
                source = "${config.programs.mnw.finalPackage.configDir}/pack/mnw/start";
                target = "lzl/lua_plugins";
              };
              fix_treesitter = {
                enable = true;
                source = "${config.programs.mnw.finalPackage.configDir}/pack/mnw/start/nvim-treesitter-grammars";
                target = "mnw/site";
              };
              lzl-plugs = {
                enable = true;
                source = "${config.programs.mnw.finalPackage.configDir}/pack/mnw/opt";
                target = "lzl/mnw-plugins";
              };
            };

            # Packages: latex, mac-specific, and optionally nvim-dev
            home.packages =
              lib.lists.optionals cfg.latex (
                with pkgs;
                [
                  texliveFull
                  ghostscript_headless
                ]
              )
              ++ lib.lists.optional cfg.dev (mkDevNeovim config.programs.mnw.finalPackage)
              ++ shared.macList [
                xcode-build-server-pkg
                pkgs.xcbeautify
                pkgs.pipx
                (pkgs.ruby.withPackages (ps: with ps; [ xcodeproj ]))
                remote-debugger
                pkgs.tuist
              ];

            programs.sioyek = lib.mkIf cfg.latex {
              enable = true;
            };
          };
        };

    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        shared = mkShared {
          inherit pkgs;
          lib = nixpkgs.lib;
        };

        # Build standalone packages using mnw directly
        mkNeovimPackage =
          extraConfig:
          mnw.lib.wrap pkgs (
            {
              neovim = pkgs.neovim-unwrapped;

              plugins.start = shared.pluginsStart;
              plugins.opt = shared.pluginsOpt;

              plugins.dev.myconf = {
                pure = ./.;
                impure = "/Users/isaac/.config/nvim";
              };

              initLua = # lua
                ''
                  require("cfg")
                '';

              extraBinPath = shared.extraBinPath;

              providers = shared.providers;
            }
            // extraConfig
          );
      in
      {
        packages = {
          default = mkNeovimPackage { };
          neovim-dev = (mkNeovimPackage { }).devMode;
        };

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            lua-language-server
            stylua
            nixd
            nixfmt
          ];
        };
      }
    )
    // {
      # System-independent outputs
      homeManagerModules.default = homeManagerModule;
      homeManagerModules.neovim-ide = homeManagerModule;
    };
}

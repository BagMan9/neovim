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

          # Plugin fetches - these will eventually move to my_stdlib
          xcodebuild-src = pkgs.fetchFromGitHub {
            owner = "wojciech-kulik";
            repo = "xcodebuild.nvim";
            rev = "0e6e3058a44622866219151209943a2120be66b5";
            hash = "sha256-9VSj5vKKUIUEHsh8MrLjqCAOtf+0a10pDikzOSNTtbs=";
          };

          claudecode-nvim = pkgs.vimUtils.buildVimPlugin {
            pname = "claudecode.nvim";
            version = "2025-06-29";
            src = pkgs.fetchFromGitHub {
              owner = "coder";
              repo = "claudecode.nvim";
              rev = "91357d810ccf92f6169f3754436901c6ff5237ec";
              hash = "sha256-h56TYz3SvdYw2R6f+NCtiFk3BRRV1+hOVa+BKjnav8E=";
            };
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

          remote-debugger = pkgs.writeShellScriptBin "remote_debugger" (
            builtins.readFile "${xcodebuild-src}/tools/remote_debugger"
          );

          # Platform helpers
          isMac = pkgs.stdenv.hostPlatform.isDarwin;
          macList = xs: lib.lists.optionals isMac xs;

          # External packages from inputs
          xcode-build-server-pkg = xcode-build-server.packages.${pkgs.system}.xcode-build or null;

          # Mac-specific extra binaries for extraBinPath
          macExtraBin = macList (
            with pkgs;
            [
              imagemagick
              coreutils
            ]
          );

          # Safe neovim-unwrapped with fixed meta
          safe-neovim-unwrapped = pkgs.neovim-unwrapped.overrideAttrs (old: {
            meta = old.meta // {
              description = "neovim unwrapped";
              longDescription = old.meta.longDescription or "";
            };
          });

          # Create a renamed dev neovim package (nvim-dev binary)
          mkDevNeovim =
            basePkg:
            pkgs.runCommand "nvim-dev" { } ''
              mkdir -p $out/bin
              ln -s ${basePkg.devMode}/bin/nvim $out/bin/nvim-dev
            '';

          # Build the mnw config (always includes impure path for devMode support)
          mkMnwConfig = {
            enable = true;
            neovim = safe-neovim-unwrapped;

            plugins.dev.myconf = {
              pure = ./.;
              impure = "${config.xdg.configHome}/nvim";
            };

            plugins.start = [
              pkgs.vimPlugins.lz-n
              pkgs.vimPlugins.nvim-treesitter.withAllGrammars
            ];

            extraBinPath =
              with pkgs;
              [
                ripgrep
                fd
                lldb
                jq
                # Lua
                lua-language-server
                stylua
                # Python
                basedpyright
                ruff
                # Bash
                bash-language-server
                shfmt
                # Nix
                nixd
                nixfmt
                # Yaml
                yaml-language-server
                python313Packages.debugpy
                # JSON
                vscode-json-languageserver
                # JS
                svelte-language-server
                typescript-language-server
                # Rust
                rustfmt
                clippy
              ]
              ++ lib.lists.optionals cfg.latex [
                texlab
                texliveFull
                ghostscript_headless
              ]
              ++ macExtraBin;

            plugins.opt =
              with pkgs.vimPlugins;
              [
                claudecode-nvim
                snacks-nvim
                fidget-nvim
                telescope-nvim
                edgy-nvim
                auto-session
                bufferline-nvim
                cmp-buffer
                cmp-nvim-lsp
                cmp-path
                cmp_luasnip
                conform-nvim
                smart-splits-nvim
                dashboard-nvim
                dressing-nvim
                flash-nvim
                flit-nvim
                leap-nvim
                friendly-snippets
                gitsigns-nvim
                indent-blankline-nvim
                lualine-nvim
                neo-tree-nvim
                neoconf-nvim
                neodev-nvim
                noice-nvim
                nui-nvim
                nvim-lint
                nvim-lspconfig
                nvim-notify
                lazydev-nvim
                nvim-treesitter-context
                nvim-treesitter-textobjects
                nvim-ts-autotag
                nvim-ts-context-commentstring
                nvim-web-devicons
                mini-icons
                persistence-nvim
                plenary-nvim
                telescope-fzf-native-nvim
                todo-comments-nvim
                tokyonight-nvim
                trouble-nvim
                vim-illuminate
                vim-startuptime
                which-key-nvim
                colorful-menu-nvim
                harpoon2
                grug-far-nvim
                blink-cmp
                mini-pairs
                mini-ai
                mini-indentscope
                mini-hipatterns
                mini-surround
                yanky-nvim
                vim-repeat
                catppuccin-nvim
                nvim-scissors
                inc-rename-nvim
                nvim-navic
                refactoring-nvim
                nvim-dap-ui
                nvim-dap
                nvim-dap-virtual-text
                SchemaStore-nvim
                nvim-surround
                comment-nvim
                nvim-dap-python
                gitlinker-nvim
                render-markdown-nvim
                avante-nvim
                blink-cmp-avante
                kulala-nvim
                octo-nvim
                blink-compat
                blink-cmp-git
                neogen
                rustaceanvim
                crates-nvim
              ]
              ++ macList [ xcodebuild-nvim ]
              ++ lib.lists.optionals cfg.latex [
                vimtex
                cmp-vimtex
              ];

            providers = {
              python3 = {
                enable = true;
                extraPackages = ps: [ ps.debugpy ];
              };
            };
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
          };

          config = lib.mkIf cfg.enable {

            programs.mnw = lib.mkMerge [
              mkMnwConfig
              cfg.mnw
              { initLua = ''require("cfg")''; }
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
              ++ macList [
                xcode-build-server-pkg
                pkgs.xcbeautify
                pkgs.pipx
                (pkgs.ruby.withPackages (ps: with ps; [ xcodeproj ]))
                remote-debugger
                pkgs.tuist
              ];

            # Sioyek for latex PDF viewing
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

        # Plugin fetches (duplicated here for standalone builds)
        xcodebuild-src = pkgs.fetchFromGitHub {
          owner = "wojciech-kulik";
          repo = "xcodebuild.nvim";
          rev = "0e6e3058a44622866219151209943a2120be66b5";
          hash = "sha256-9VSj5vKKUIUEHsh8MrLjqCAOtf+0a10pDikzOSNTtbs=";
        };

        claudecode-nvim = pkgs.vimUtils.buildVimPlugin {
          pname = "claudecode.nvim";
          version = "2025-06-29";
          src = pkgs.fetchFromGitHub {
            owner = "coder";
            repo = "claudecode.nvim";
            rev = "91357d810ccf92f6169f3754436901c6ff5237ec";
            hash = "sha256-h56TYz3SvdYw2R6f+NCtiFk3BRRV1+hOVa+BKjnav8E=";
          };
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

        isMac = pkgs.stdenv.hostPlatform.isDarwin;
        macList = xs: nixpkgs.lib.lists.optionals isMac xs;

        # Build standalone packages using mnw directly
        mkNeovimPackage =
          extraConfig:
          mnw.lib.wrap pkgs (
            {
              neovim = pkgs.neovim-unwrapped;

              plugins.start = [
                pkgs.vimPlugins.lz-n
                pkgs.vimPlugins.nvim-treesitter.withAllGrammars
              ];

              plugins.opt =
                with pkgs.vimPlugins;
                [
                  claudecode-nvim
                  snacks-nvim
                  fidget-nvim
                  telescope-nvim
                  edgy-nvim
                  auto-session
                  bufferline-nvim
                  cmp-buffer
                  cmp-nvim-lsp
                  cmp-path
                  cmp_luasnip
                  conform-nvim
                  smart-splits-nvim
                  dashboard-nvim
                  dressing-nvim
                  flash-nvim
                  flit-nvim
                  leap-nvim
                  friendly-snippets
                  gitsigns-nvim
                  indent-blankline-nvim
                  lualine-nvim
                  neo-tree-nvim
                  neoconf-nvim
                  neodev-nvim
                  noice-nvim
                  nui-nvim
                  nvim-lint
                  nvim-lspconfig
                  nvim-notify
                  lazydev-nvim
                  nvim-treesitter-context
                  nvim-treesitter-textobjects
                  nvim-ts-autotag
                  nvim-ts-context-commentstring
                  nvim-web-devicons
                  mini-icons
                  persistence-nvim
                  plenary-nvim
                  telescope-fzf-native-nvim
                  todo-comments-nvim
                  tokyonight-nvim
                  trouble-nvim
                  vim-illuminate
                  vim-startuptime
                  which-key-nvim
                  colorful-menu-nvim
                  harpoon2
                  grug-far-nvim
                  blink-cmp
                  mini-pairs
                  mini-ai
                  mini-indentscope
                  mini-hipatterns
                  mini-surround
                  yanky-nvim
                  vim-repeat
                  catppuccin-nvim
                  nvim-scissors
                  inc-rename-nvim
                  nvim-navic
                  refactoring-nvim
                  nvim-dap-ui
                  nvim-dap
                  nvim-dap-virtual-text
                  SchemaStore-nvim
                  nvim-surround
                  comment-nvim
                  nvim-dap-python
                  gitlinker-nvim
                  render-markdown-nvim
                  avante-nvim
                  blink-cmp-avante
                  kulala-nvim
                  octo-nvim
                  blink-compat
                  blink-cmp-git
                  neogen
                  rustaceanvim
                  crates-nvim
                ]
                ++ macList [ xcodebuild-nvim ];

              plugins.dev.myconf = {
                pure = ./.;
                impure = "/Users/isaac/.config/nvim";
              };

              initLua = # lua
                ''
                  require("cfg")
                '';

              extraBinPath = with pkgs; [
                ripgrep
                fd
                lldb
                jq
                lua-language-server
                stylua
                basedpyright
                ruff
                bash-language-server
                shfmt
                nixd
                nixfmt
                yaml-language-server
                python313Packages.debugpy
                vscode-json-languageserver
                svelte-language-server
                typescript-language-server
                rustfmt
                clippy
              ];

              providers.python3 = {
                enable = true;
                extraPackages = ps: [ ps.debugpy ];
              };
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

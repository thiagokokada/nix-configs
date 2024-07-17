{ flake }:
final: prev:

let
  inherit (flake) outputs inputs;
in
outputs.lib.recursiveMergeAttrs [
  (inputs.nixgl.overlays.default final prev)
  {
    # namespaces
    libEx = outputs.lib;

    wallpapers = prev.callPackage ../packages/wallpapers { };

    # custom packages
    arandr = prev.arandr.overrideAttrs (_: {
      src = inputs.arandr;
    });

    anime4k = prev.callPackage ../packages/anime4k { };

    # https://github.com/NixOS/nixpkgs/pull/327866
    any-nix-shell = prev.any-nix-shell.overrideAttrs (_: {
      version = "1.2.1-unstable-2023-11-08";

      src = prev.fetchFromGitHub {
        owner = "haslersn";
        repo = "any-nix-shell";
        rev = "2537e5c6901ef934f8f44d61bcfe938b0fc9fa71";
        hash = "sha256-j1DE0WTBGLmBLoPmqST9YVj9Jc4Mp8WXQILmPBzRlbM=";
      };

      patches = [
        (prev.fetchpatch2 {
          name = "add_support_for_the_nix_develop_command.patch";
          url = "https://github.com/haslersn/any-nix-shell/commit/f048649700a047150d3bbc399869c4e003c96125.patch";
          hash = "sha256-Bl4akNy3Aj7LkHTnKOsIdYbIc8LvFH7rjg89QPoLaYk=";
        })
      ];
    });

    inherit (inputs.home-manager.packages.${prev.system}) home-manager;

    open-browser = prev.callPackage ../packages/open-browser { };

    neovim-standalone =
      let
        hostname = "neovim";
        hm =
          (outputs.lib.mkHomeConfig {
            inherit hostname;
            inherit (prev) system;
            extraModules = [
              {
                home-manager = {
                  dev.nix.enable = true;
                  editor.neovim = {
                    icons.enable = false;
                    lsp.enable = true;
                    treeSitter.enable = true;
                  };
                };
              }
            ];
          }).homeConfigurations.${hostname};
      in
      hm.config.programs.neovim.finalPackage.override {
        luaRcContent = hm.config.xdg.configFile."nvim/init.lua".text;
        wrapRc = true;
      };

    nix-cleanup = prev.callPackage ../packages/nix-cleanup { };

    nixos-cleanup = prev.callPackage ../packages/nix-cleanup { isNixOS = true; };

    nix-whereis = prev.callPackage ../packages/nix-whereis { };

    # https://github.com/NixOS/nixpkgs/issues/97855#issuecomment-1075818028
    nixos-option =
      let
        prefix = ''
          (import ${inputs.flake-compat} {
            src = ${flake};
          }).defaultNix.nixosConfigurations.\$(hostname)
        '';
      in
      prev.runCommand "nixos-option"
        {
          buildInputs = with prev; [
            makeWrapper
            installShellFiles
          ];
        }
        ''
          makeWrapper ${prev.nixos-option}/bin/nixos-option $out/bin/nixos-option \
          --add-flags --config_expr \
          --add-flags "\"${prefix}.config\"" \
          --add-flags --options_expr \
          --add-flags "\"${prefix}.options\""

          installManPage ${prev.nixos-option}/share/man/**/*
        '';

    run-bg-alias = name: command: prev.callPackage ../packages/run-bg-alias { inherit name command; };
  }
]

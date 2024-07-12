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

    nom-rebuild = prev.callPackage ../packages/nom-rebuild { };

    run-bg-alias = name: command: prev.callPackage ../packages/run-bg-alias { inherit name command; };
  }
]

{ pkgs, flake, ... }:

let
  inherit (flake) inputs;
in
{
  nixpkgs.overlays = [
    inputs.emacs.overlay

    (final: prev: {
      # namespaces
      lib = prev.lib.extend (finalLib: prevLib:
        (import ../lib { lib = finalLib; })
      );

      gaming = flake.inputs.nix-gaming.packages.${pkgs.system};

      wallpapers = prev.callPackage ../packages/wallpapers { };

      # custom packages
      arandr = prev.arandr.overrideAttrs (_: { src = inputs.arandr; });

      anime4k = prev.callPackage ../packages/anime4k { };

      change-res = prev.callPackage ../packages/change-res { };

      home-manager = flake.inputs.home.packages.${pkgs.system}.home-manager;

      open-browser = prev.callPackage ../packages/open-browser { };

      nix-whereis = prev.callPackage ../packages/nix-whereis { };

      nix-cleanup = prev.callPackage ../packages/nix-cleanup { };

      nixos-cleanup = prev.callPackage ../packages/nix-cleanup { isNixOS = true; };

      # https://github.com/NixOS/nixpkgs/issues/97855#issuecomment-1075818028
      nixos-option =
        let
          prefix = ''
            (import ${flake.inputs.flake-compat} {
              src = ${flake};
            }).defaultNix.nixosConfigurations.\$(hostname)
          '';
        in
        prev.runCommandNoCC "nixos-option" { buildInputs = [ prev.makeWrapper ]; } ''
          makeWrapper ${prev.nixos-option}/bin/nixos-option $out/bin/nixos-option \
            --add-flags --config_expr \
            --add-flags "\"${prefix}.config\"" \
            --add-flags --options_expr \
            --add-flags "\"${prefix}.options\""
        '';

      nom-rebuild = prev.callPackage ../packages/nom-rebuild { };

      run-bg-alias = name: command: prev.callPackage ../packages/run-bg-alias { inherit name command; };

      swaylock-effects = prev.swaylock-effects.overrideAttrs (oldAttrs: {
        # https://github.com/jirutka/swaylock-effects/pull/38
        patches = (oldAttrs.patches or [ ]) ++ [
          (prev.fetchpatch {
            url = "https://github.com/jirutka/swaylock-effects/commit/18573cb795592b4ab82f7693c151923d9e08cbb5.patch";
            hash = "sha256-ogFhSsONuCToLFIStUaA+GTm8qBKJrg7s6VMDBvF1Bc=";
          })
          (prev.fetchpatch {
            url = "https://github.com/jirutka/swaylock-effects/commit/071bfa4f584593de4dd91f052419767bc30d0b4b.patch";
            hash = "sha256-Tk8AXtt7eszuHe918YUNAgSGqc73mTYpZ14R6wB33Sw=";
          })
        ];
      });
    })
  ];
}

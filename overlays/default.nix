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
        prev.runCommand "nixos-option" { buildInputs = with prev; [ makeWrapper installShellFiles ]; } ''
          makeWrapper ${prev.nixos-option}/bin/nixos-option $out/bin/nixos-option \
            --add-flags --config_expr \
            --add-flags "\"${prefix}.config\"" \
            --add-flags --options_expr \
            --add-flags "\"${prefix}.options\""

          installManPage ${prev.nixos-option}/share/man/**/*
        '';

      nom-rebuild = prev.callPackage ../packages/nom-rebuild { };

      run-bg-alias = name: command: prev.callPackage ../packages/run-bg-alias { inherit name command; };

      swaylock-effects = prev.swaylock-effects.overrideAttrs (_: { src = inputs.swaylock-effects; });
    })
  ];
}

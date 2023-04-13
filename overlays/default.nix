{ pkgs, lib, flake, system, ... }:

let
  inherit (flake) inputs;
in
{
  nixpkgs.overlays = [
    inputs.emacs.overlay

    (final: prev: {
      # namespaces
      lib = prev.lib.extend (finalLib: prevLib:
        (import ../lib { inherit (prev) lib; })
      );

      stable = import inputs.stable {
        inherit system;
        config = prev.config;
      };

      gaming = flake.inputs.nix-gaming.packages.${system};

      wallpapers = prev.callPackage ../packages/wallpapers { };

      # custom packages
      arandr = prev.arandr.overrideAttrs (_: { src = inputs.arandr; });

      archivers = prev.callPackage ../packages/archivers { };

      change-res = prev.writeShellApplication {
        name = "change-res";
        runtimeInputs = with prev; [ autorandr ];
        text = ''
          # Do not run this script in a Sway session
          if systemctl --quiet --user is-active sway-session.target; then
            exit 0
          fi
          autorandr --change || autorandr --common
          systemctl --user restart wallpaper.service
        '';
      };

      open-browser = prev.callPackage ../packages/open-browser { };

      nix-whereis = prev.callPackage ../packages/nix-whereis { };

      nix-cleanup = prev.callPackage ../packages/nix-cleanup { };

      nixos-cleanup = prev.callPackage ../packages/nix-cleanup { isNixOS = true; };

      nom-rebuild = prev.callPackage ../packages/nom-rebuild { };

      run-bg-alias = name: command: prev.callPackage ../packages/run-bg-alias { inherit name command; };
    })
  ];
}

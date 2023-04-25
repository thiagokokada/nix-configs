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

      gaming = flake.inputs.nix-gaming.packages.${system};

      wallpapers = prev.callPackage ../packages/wallpapers { };

      # custom packages
      arandr = prev.arandr.overrideAttrs (_: { src = inputs.arandr; });

      change-res = prev.callPackage ../packages/change-res { };

      open-browser = prev.callPackage ../packages/open-browser { };

      nix-whereis = prev.callPackage ../packages/nix-whereis { };

      nix-cleanup = prev.callPackage ../packages/nix-cleanup { };

      nixos-cleanup = prev.callPackage ../packages/nix-cleanup { isNixOS = true; };

      nom-rebuild = prev.callPackage ../packages/nom-rebuild { };

      run-bg-alias = name: command: prev.callPackage ../packages/run-bg-alias { inherit name command; };
    })
  ];
}

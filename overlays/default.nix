{ pkgs, lib, self, system, ... }:

let
  inherit (self) inputs;
in
{
  nixpkgs.overlays = [
    inputs.emacs.overlay

    (final: prev: {
      lib = prev.lib.extend (finalLib: prevLib: {
        utils = import ../utils { pkgs = final; };
      });

      unstable = import inputs.unstable {
        inherit system;
        config = prev.config;
      };

      open-browser = prev.callPackage ../packages/open-browser { };

      nix-whereis = prev.callPackage ../packages/nix-whereis { };

      nixos-cleanup = prev.callPackage ../packages/nixos-cleanup { };

      wallpapers = prev.callPackage ../packages/wallpapers { };

      nixpkgs-review =
        if (prev.stdenv.isLinux) then
          inputs.nixpkgs-review.packages.${system}.nixpkgs-review-sandbox
        else
          inputs.nixpkgs-review.packages.${system}.nixpkgs-review;
    })
  ];
}

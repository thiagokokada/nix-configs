{ pkgs, lib, self, system, ... }:

let
  inherit (self) inputs;
in
{
  nixpkgs.overlays = [
    inputs.emacs.overlay

    (final: prev: {
      unstable = import inputs.unstable {
        inherit system;
        config = prev.config;
      };

      open-browser = prev.callPackage ../packages/open-browser { };

      nix-whereis = prev.callPackage ../packages/nix-whereis { };

      nixos-cleanup = prev.callPackage ../packages/nixos-cleanup { };

      # TODO: on 21.11, use programs.htop.package instead
      htop = prev.htop.overrideAttrs (oldAttrs: rec {
        pname = "htop-vim";
        version = self.inputs.htop-vim.shortRev;
        src = self.inputs.htop-vim;
      });

      # TODO: remove it from 21.11
      delta = final.unstable.delta;
      pamixer = final.unstable.pamixer;
      rar = final.unstable.rar;
    })
  ];
}

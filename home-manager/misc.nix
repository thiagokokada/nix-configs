{ config, lib, pkgs, inputs, system, ... }:

{
  nixpkgs.overlays = [
    (final: prev: rec {
      unstable = import inputs.unstable {
        inherit system;
        config = prev.config;
      };
    })
  ];
}

{ pkgs, lib, flake, osConfig, ... }:

{
  imports = [
    ../modules
    ./cli
    ./darwin.nix
    ./desktop
    ./dev
    ./editor
    ./meta
  ];

  # Inherit config from NixOS or homeConfigurations
  inherit (osConfig) device mainUser;

  nixpkgs.overlays = [ (import ../overlays { inherit flake; }) ];

  # Assume that this is a non-NixOS system
  targets.genericLinux.enable = lib.mkIf pkgs.stdenv.isLinux (lib.mkDefault true);
}

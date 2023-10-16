{ flake, osConfig, ... }:

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

  nixpkgs.overlays = [ (import ../overlays { inherit flake; }) ];

  # Inherit config from NixOS or homeConfigurations
  inherit (osConfig) device mainUser;
}

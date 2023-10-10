{ osConfig, ... }:

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
  inherit (osConfig) device meta;
}

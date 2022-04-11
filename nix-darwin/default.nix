{ config, lib, pkgs, ... }:

{
  imports = [
    ./home.nix
    ./system.nix
    ./meta.nix
    ../modules
    ../overlays
  ];
}

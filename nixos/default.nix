{ config, lib, pkgs, ... }:

{
  imports = [
    ./desktop.nix
    ./dev.nix
    ./fonts.nix
    ./home.nix
    ./minimal.nix
    ./xserver.nix
  ];
}

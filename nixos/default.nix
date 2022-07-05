{ config, lib, pkgs, flake, ... }:

{
  imports = [
    ./desktop.nix
    ./dev.nix
    ./fonts.nix
    ./home.nix
    ./laptop.nix
    ./minimal.nix
    ./non-nix.nix
    ./wayland.nix
    ./xserver.nix
  ];
}

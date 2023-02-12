{ config, lib, pkgs, flake, ... }:

{
  imports = [
    ./audio.nix
    ./desktop.nix
    ./dev.nix
    ./fonts.nix
    ./home.nix
    ./laptop.nix
    ./minimal.nix
    ./wayland.nix
    ./xserver.nix
  ];
}

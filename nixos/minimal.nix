{ config, lib, pkgs, ... }:

{
  imports = [
    ./cli.nix
    ./locale.nix
    ./meta.nix
    ./system.nix
    ./user.nix
    ../modules
  ];
}

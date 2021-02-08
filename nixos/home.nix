{ config, lib, pkgs, ... }:

let
  inherit (config.my) username;
in {
  home-manager.useUserPackages = true;
  home-manager.users.${username} = ../home-manager/home.nix;
}

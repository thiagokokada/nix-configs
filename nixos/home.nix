{ config, lib, pkgs, inputs, system, ... }:

with lib;
let inherit (config.my) username;
in {
  home-manager.useUserPackages = true;
  home-manager.users.${username} = ../home-manager/home.nix;
  home-manager.extraSpecialArgs = { inherit inputs system; };
}

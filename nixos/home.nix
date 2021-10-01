{ config, lib, pkgs, inputs, system, ... }:

with lib;
let inherit (config.meta) username;
in
{
  imports = [ inputs.home.nixosModules.home-manager ];

  home-manager = {
    useUserPackages = true;
    users.${username} = ../home-manager;
    extraSpecialArgs = {
      inherit inputs system;
      super = config;
    };
  };
}

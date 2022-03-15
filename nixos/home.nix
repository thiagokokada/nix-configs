{ config, lib, pkgs, self, system, ... }:

let
  inherit (config.meta) username;
in
{
  imports = [ self.inputs.home.nixosModules.home-manager ];

  home-manager = {
    useUserPackages = true;
    users.${username} = ../home-manager/nixos.nix;
    extraSpecialArgs = {
      inherit self system;
      super = config;
    };
  };
}

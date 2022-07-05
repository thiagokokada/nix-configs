{ config, lib, pkgs, flake, system, ... }:

let
  inherit (config.meta) username;
in
{
  imports = [
    flake.inputs.home.nixosModules.home-manager
    ../modules/meta.nix
  ];

  home-manager = {
    useUserPackages = true;
    users.${username} = ../home-manager/nixos.nix;
    extraSpecialArgs = {
      inherit flake system;
      super = config;
    };
  };
}

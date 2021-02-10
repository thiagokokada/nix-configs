{ config, lib, pkgs, inputs, system, ... }:

with lib;
let inherit (config.my) username;
in {
  # "submodule types have merging semantics" -- bqv
  options.home-manager.users = mkOption {
    type = with types; attrsOf (submoduleWith {
      modules = [ ];
      # Makes specialArgs available to home-manager modules as well
      specialArgs = {
        inherit inputs system;
      };
    });
  };

  config.home-manager.useUserPackages = true;
  config.home-manager.users.${username} = ../home-manager/home.nix;
}

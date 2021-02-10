{ config, lib, pkgs, inputs, system, ... }:

with lib;
let inherit (config.my) username;
in {
  # https://github.com/nix-community/home-manager/pull/1793
  options.home-manager.users = mkOption {
    type = with types;
      attrsOf (submoduleWith {
        modules = [ ];
        # Makes specialArgs available to home-manager modules as well
        specialArgs = { inherit inputs system; };
      });
  };

  config.home-manager.useUserPackages = true;
  config.home-manager.users.${username} = ../home-manager/home.nix;
}

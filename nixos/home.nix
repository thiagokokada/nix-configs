{ config, lib, pkgs, flake, system, ... }:

{
  imports = [
    flake.inputs.home.nixosModules.home-manager
    ../modules/meta.nix
  ];

  options.nixos.home = {
    enable = pkgs.lib.mkDefaultOption "home config";
    username = lib.mkOption {
      description = "Main username";
      type = lib.types.str;
      default = config.meta.username;
    };
  };

  config = lib.mkIf config.nixos.home.enable {
    home-manager = {
      useUserPackages = true;
      users.${config.nixos.home.username} = ../home-manager/nixos.nix;
      extraSpecialArgs = {
        inherit flake system;
        super = config;
      };
    };
  };
}

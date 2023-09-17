{ config, lib, flake, pkgs, ... }:

let
  cfg = config.nixos.home;
in
{
  imports = [
    flake.inputs.home.nixosModules.home-manager
    ../modules/meta.nix
  ];

  options.nixos.home = {
    enable = lib.mkDefaultOption "home config";
    username = lib.mkOption {
      description = "Main username";
      type = lib.types.str;
      default = config.meta.username;
    };
    imports = lib.mkOption {
      description = "Modules to import";
      type = lib.types.listOf lib.types.path;
      default = [ ../home-manager/nixos.nix ];
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager = {
      useUserPackages = true;
      users.${cfg.username} = {
        inherit (config.nixos.home) imports;
      };
      extraSpecialArgs = { inherit flake; };
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${cfg.username} = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [ "wheel" "networkmanager" "video" ];
      shell = pkgs.zsh;
      password = "changeme";
    };
  };
}

{ config, lib, libEx, flake, pkgs, ... }:

let
  cfg = config.nixos.home;
in
{
  imports = [ flake.inputs.home-manager.nixosModules.home-manager ];

  options.nixos.home = {
    enable = lib.mkEnableOption "home config" // { default = true; };
    imports = lib.mkOption {
      description = "Modules to import";
      type = lib.types.listOf lib.types.path;
      default = [ ../home-manager/nixos.nix ];
    };
  };

  config = lib.mkIf cfg.enable {
    # Home-Manager standalone already adds home-manager to PATH, so we
    # are adding here only for NixOS
    environment.systemPackages = with pkgs; [ home-manager ];

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      users.${config.mainUser.username} = {
        inherit (config.nixos.home) imports;
      };
      extraSpecialArgs = {
        inherit flake libEx;
      };
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${config.mainUser.username} = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [ "wheel" "networkmanager" "video" ];
      shell = pkgs.zsh;
      password = "changeme";
    };
  };
}

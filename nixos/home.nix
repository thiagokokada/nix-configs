{
  config,
  lib,
  libEx,
  flake,
  pkgs,
  ...
}:

let
  cfg = config.nixos.home;
in
{
  imports = [ flake.inputs.home-manager.nixosModules.home-manager ];

  options.nixos.home = {
    enable = lib.mkEnableOption "home config" // {
      default = true;
    };
    extraModules = lib.mkOption {
      description = "Extra modules to import.";
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
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
        imports = [
          ../home-manager
          { targets.genericLinux.enable = false; }
        ] ++ cfg.extraModules;
        # As a rule of thumb HM == NixOS version, unless something weird happens
        home.stateVersion = lib.mkDefault config.system.stateVersion;
      };
      extraSpecialArgs = {
        inherit flake libEx;
      };
    };

    # Define a user account. Don't forget to set a password with ‘passwd’
    users.users.${config.mainUser.username} = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [
        "wheel"
        "networkmanager"
        "video"
      ];
      shell = pkgs.zsh;
      password = "changeme";
    };
  };
}

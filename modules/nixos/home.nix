{
  config,
  lib,
  flake,
  pkgs,
  ...
}:

let
  cfg = config.nixos.home;
in
{
  imports = [
    (flake.outputs.internal.sharedModules.helpers.mkHomeModule "nixos")
    flake.inputs.home-manager.nixosModules.home-manager
  ];

  config = lib.mkIf cfg.enable {
    nixos.home.extraModules = {
      # As a rule of thumb HM == NixOS version, unless something weird happens
      home.stateVersion = lib.mkDefault config.system.stateVersion;
    };

    # Define a user account. Don't forget to set a password with ‘passwd’
    users.users.${cfg.username} = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [
        "wheel"
        "video"
      ];
      shell = pkgs.zsh;
      password = "changeme";
    };
  };
}

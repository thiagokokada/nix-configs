{
  lib,
  config,
  flake,
  ...
}:

let
  inherit (config.meta) username;
  cfg = config.nixos.games.jovian;
in
{
  imports = [
    flake.inputs.chaotic-nyx.nixosModules.default
    flake.inputs.jovian-nixos.nixosModules.default
  ];

  options.nixos.games.jovian = {
    enable = lib.mkEnableOption "Jovian-NixOS config" // {
      default = config.device.type == "steam-machine";
    };
    bootInDesktopMode = lib.mkEnableOption "boot in desktop mode by default";
  };

  config = lib.mkIf cfg.enable {
    chaotic = {
      mesa-git.enable = true;
    };

    jovian = {
      steam = {
        enable = true;
        autoStart = true;
        user = username;
        desktopSession = "plasma";
      };
      hardware.has.amd.gpu = config.nixos.system.gpu == "amd";
    };

    services.desktopManager.plasma6.enable = true;

    # https://github.com/Jovian-Experiments/Jovian-NixOS/discussions/488
    home-manager.users.${username} = lib.mkIf cfg.bootInDesktopMode {
      xdg.stateFile."steamos-session-select".text = config.jovian.steam.desktopSession;
    };
  };
}

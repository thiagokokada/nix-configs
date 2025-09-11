{
  config,
  lib,
  pkgs,
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
      # This will break NVIDIA Optimus, and doesn't make lots of sense if using
      # proprietary drivers anyway
      # TODO: add Intel?
      mesa-git.enable = config.nixos.system.gpu == "amd";
    };

    jovian = {
      steam = {
        enable = true;
        autoStart = true;
        user = username;
        desktopSession = config.services.displayManager.defaultSession;
      };
      hardware.has.amd.gpu = config.nixos.system.gpu == "amd";
    };

    programs.steam.extraCompatPackages = with pkgs; [
      proton-cachyos
      proton-ge-custom
    ];

    # https://github.com/Jovian-Experiments/Jovian-NixOS/discussions/488
    home-manager.users.${username} = lib.mkIf cfg.bootInDesktopMode {
      xdg.stateFile."steamos-session-select".text = config.jovian.steam.desktopSession;
    };
  };
}

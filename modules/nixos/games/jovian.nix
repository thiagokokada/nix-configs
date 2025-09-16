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
        environment = {
          STEAM_EXTRA_COMPAT_TOOLS_PATHS =
            lib.makeSearchPathOutput "steamcompattool" ""
              config.programs.steam.extraCompatPackages;
        };
      };
      hardware.has.amd.gpu = config.nixos.system.gpu == "amd";
    };

    programs.steam.extraCompatPackages = with pkgs; [
      proton-cachyos
      proton-ge-custom
    ];

    home-manager.users.${username} = {
      home.file."Desktop/Return-to-Gaming-Mode.desktop".source =
        (pkgs.makeDesktopItem {
          desktopName = "Return to Gaming Mode";
          exec = "qdbus org.kde.Shutdown /Shutdown org.kde.Shutdown.logout";
          icon = "steam";
          name = "Return-to-Gaming-Mode";
          startupNotify = false;
          terminal = false;
          type = "Application";
        })
        + "/share/applications/Return-to-Gaming-Mode.desktop";
    };

    specialisation.desktop-mode.configuration = {
      # https://github.com/Jovian-Experiments/Jovian-NixOS/discussions/488
      home-manager.users.${username}.xdg.stateFile."steamos-session-select" = {
        text = config.jovian.steam.desktopSession;
      };
    };
  };
}

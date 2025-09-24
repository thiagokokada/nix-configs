{
  config,
  lib,
  pkgs,
  flake,
  ...
}:

let
  inherit (config.nixos.home) username;
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
    bootInDesktopMode = lib.mkEnableOption "boot in desktop mode";
  };

  config = lib.mkIf cfg.enable {
    chaotic = {
      # This will break NVIDIA Optimus, and doesn't make lots of sense if using
      # proprietary drivers anyway
      # TODO: add Intel?
      mesa-git.enable = config.nixos.system.gpu.maker == "amd";
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
      # Upstream disables amd_iommu, this is annoying so we are setting
      # our own settings (see nixos.system.gpu == "amd")
      steamos.enableDefaultCmdlineConfig = !config.nixos.dev.virtualisation.libvirt.enable;
      hardware.has.amd.gpu = config.nixos.system.gpu.maker == "amd";
    };

    programs.steam.extraCompatPackages = with pkgs; [
      proton-cachyos
      proton-ge-custom
    ];

    nixos.home.extraModules = {
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

      # Automatically mount disks in Gamescope session
      services.udiskie = {
        enable = lib.mkDefault true;
        # Assuming KDE here, we will already have notifications from it
        notify = lib.mkDefault false;
        # Disable tray otherwise this service depends on tray.target (that
        # Gamescope session does not start)
        tray = "never";
      };

      xdg.stateFile."steamos-session-select" = lib.mkIf cfg.bootInDesktopMode {
        text = config.jovian.steam.desktopSession;
      };
    };

    specialisation = {
      game-mode = lib.mkIf cfg.bootInDesktopMode {
        configuration = {
          nixos.games.jovian.bootInDesktopMode = false;
        };
      };
      desktop-mode = lib.mkIf (!cfg.bootInDesktopMode) {
        configuration = {
          nixos.games.jovian.bootInDesktopMode = true;
        };
      };
    };
  };
}

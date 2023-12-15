{ pkgs, lib, config, ... }:

let
  cfg = config.nixos.games;
  nvidia-offload = lib.findFirst (p: lib.isDerivation p && p.name == "nvidia-offload")
    null
    config.environment.systemPackages;
in
{
  imports = [
    ./corectrl.nix
    ./osu.nix
    ./ratbag.nix
    ./retroarch.nix
    ./steam.nix
  ];

  options.nixos.games = {
    enable = lib.mkEnableOption "games config";
    gpu = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "amd" "intel" "nvidia" ]);
      default = null;
      description = "GPU maker.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Fix: MESA-INTEL: warning: Performance support disabled, consider sysctl dev.i915.perf_stream_paranoid=0
    boot.kernelParams = lib.mkIf (cfg.gpu == "intel") [ "dev.i915.perf_stream_paranoid=0" ];

    environment = {
      systemPackages = with pkgs; [
        lutris
      ];

      # Use nvidia-offload script in gamemode
      variables.GAMEMODERUNEXEC = lib.mkIf (cfg.gpu == "nvidia" && nvidia-offload != null)
        "${nvidia-offload}/bin/nvidia-offload";
    };

    programs.gamemode = {
      enable = true;
      settings = {
        general = {
          softrealtime = "auto";
          renice = 10;
        };
        custom = {
          start = "${lib.getExe' pkgs.libnotify "notify-send"} 'GameMode started'";
          end = "${lib.getExe' pkgs.libnotify "notify-send"} 'GameMode ended'";
        };
      };
    };

    # Alternative driver for Xbox One/Series S/Series X controllers
    hardware.xone.enable = true;
  };
}

{ pkgs, lib, config, ... }:

let
  isInSystemPkgs = with builtins;
    name: elem name (map (p: p.name) config.environment.systemPackages);
in
{
  # Fix: MESA-INTEL: warning: Performance support disabled, consider sysctl dev.i915.perf_stream_paranoid=0
  boot.kernelParams = [ "dev.i915.perf_stream_paranoid=0" ];

  environment.systemPackages = with pkgs; [
    gaming.osu-stable
    piper
    unstable.lutris
    unstable.osu-lazer
    unstable.retroarchFull
  ];

  # Use nvidia-offload script in gamemode
  environment.variables.GAMEMODERUNEXEC = lib.mkIf (isInSystemPkgs "nvidia-offload")
    "nvidia-offload";

  programs = {
    gamemode = {
      enable = true;
      settings = {
        general = {
          softrealtime = "auto";
          renice = 10;
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };
  };

  # Alternative driver for Xbox One/Series S/Series X controllers
  hardware.xpadneo.enable = true;

  services = {
    # Enable ratbagd (i.e.: piper) for Logitech devices
    ratbagd.enable = true;
  };
}

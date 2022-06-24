{ pkgs, config, ... }:

{
  # Fix: MESA-INTEL: warning: Performance support disabled, consider sysctl dev.i915.perf_stream_paranoid=0
  boot.kernelParams = [ "dev.i915.perf_stream_paranoid=0" ];

  environment.systemPackages = with pkgs; [
    piper
    gaming.osu-stable
    unstable.lutris
    unstable.osu-lazer
    unstable.retroarchFull
  ];

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

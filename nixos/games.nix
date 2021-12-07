{ pkgs, config, ... }:

{
  # Fix: MESA-INTEL: warning: Performance support disabled, consider sysctl dev.i915.perf_stream_paranoid=0
  boot.kernelParams = [ "dev.i915.perf_stream_paranoid=0" ];

  environment.systemPackages = with pkgs; [
    piper
    unstable.lutris
    unstable.osu-lazer
    unstable.retroarchFull
  ];

  # Enable steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  # Alternative driver for Xbox One/Series S/Series X controllers
  hardware.xpadneo.enable = true;

  # Enable ratbagd (for piper).
  services.ratbagd = {
    enable = true;
  };
}

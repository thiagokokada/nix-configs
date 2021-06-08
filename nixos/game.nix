{ pkgs, config, ... }:

{
  environment.systemPackages = with pkgs; [
    piper
    unstable.lutris
    unstable.osu-lazer
  ];

  # Enable steam
  programs.steam.enable = true;

  # Enable ratbagd (for piper).
  services.ratbagd = {
    enable = true;
  };
}

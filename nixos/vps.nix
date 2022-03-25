{ config, pkgs, ... }:
{
  imports = [ ./wireguard.nix ];

  systemd.tmpfiles.rules = with config.meta; with config.services.plex; [
    "d /media/Music 2775 ${username} ${group}"
    "d /media/Photos 2775 ${username} ${group}"
    "d /media/Movies 2775 ${username} ${group}"
    "d /media/Other 2775 ${username} ${group}"
  ];

  # Enable NixOS auto-upgrade
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    flake = "/etc/nixos";
    dates = "4:40";
    flags = [
      "--recreate-lock-file"
      "--no-write-lock-file"
    ];
  };

  services = {
    fail2ban.enable = true;
    plex = {
      enable = true;
      openFirewall = true;
      package = pkgs.unstable.plex;
    };
  };
}

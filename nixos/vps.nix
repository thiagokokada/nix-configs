{ config, pkgs, ... }:
{
  imports = [
    (import ./wireguard {
      externalInterface = "ens3";
      externalUrl = "mirai-vps.duckdns.org";
    })
    ./plex.nix
  ];

  device.mediaDir = "/media";

  # Enable NixOS auto-upgrade
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    flake = "github:thiagokokada/nix-configs";
  };

  services = {
    fail2ban.enable = true;
  };
}

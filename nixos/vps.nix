{ pkgs, ... }:
{
  imports = [
    (import ./wireguard {
      externalInterface = "ens3";
      externalUrl = "mirai-vps.duckdns.org";
    })
    ./plex.nix
  ];

  device.mediaDir = "/media";

  environment.systemPackages = with pkgs; [ tailscale ];

  services.tailscale.enable = true;

  # Enable NixOS auto-upgrade
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    flake = "github:thiagokokada/nix-configs";
  };
}

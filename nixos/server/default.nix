{ lib, config, ... }:
{
  options.nixos.server.enable = lib.mkEnableOption "server config";

  imports = [
    ./plex.nix
    ./rtorrent.nix
    ./samba.nix
    ./ssh.nix
    ./tailscale.nix
    ./wireguard
  ];

  config = lib.mkIf config.nixos.server.enable {
    # Enable NixOS auto-upgrade
    system.autoUpgrade = {
      enable = true;
      allowReboot = true;
      flake = "github:thiagokokada/nix-configs";
    };
  };
}

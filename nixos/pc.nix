{ pkgs, config, lib, ... }:

let
  inherit (config.meta) username;
in
{
  imports = [
    ./libvirt
    ./rtorrent.nix
    ./plex.nix
    ./samba.nix
    ../modules/device.nix
  ];

  device.mediaDir = "/mnt/archive/${username}";

  # Some misc packages
  environment.systemPackages = with pkgs; [
    gnome.simple-scan
  ];

  # Enable scanner support
  hardware.sane.enable = true;

  users.users.${username} = { extraGroups = [ "sane" "lp" ]; };

  services = {
    # Enable printing
    printing = {
      enable = true;
      drivers = with pkgs; [ epson_201207w ];
    };
  };
}

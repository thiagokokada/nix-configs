{ pkgs, config, lib, ... }:

let
  inherit (config.meta) username;
in
{
  imports = [
    ./libvirt
    ../modules/device.nix
  ];

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

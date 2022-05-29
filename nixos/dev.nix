{ pkgs, config, ... }:
let
  inherit (config.meta) username;
in
{
  environment.systemPackages = with pkgs; [
    distrobox
    docker-compose
    gnome.gnome-boxes
  ];

  programs = {
    adb.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;

  # Added user to groups
  users.users.${username}.extraGroups = [ "adbusers" "docker" "wireshark" ];
}

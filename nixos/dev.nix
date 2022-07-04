{ pkgs, config, ... }:
let
  inherit (config.meta) username;
in
{
  environment.systemPackages = with pkgs; [
    distrobox
    gnome.gnome-boxes
    podman-compose
  ];

  programs = {
    adb.enable = true;
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
    libvirtd.enable = true;
  };

  # Added user to groups
  users.users.${username}.extraGroups = [ "adbusers" "docker" "wireshark" ];
}

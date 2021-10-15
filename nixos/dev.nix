{ pkgs, config, ... }:
let
  inherit (config.meta) username;
in
{
  environment.systemPackages = with pkgs; [
    docker-compose
    gnome.gnome-boxes
  ];

  programs = {
    adb.enable = true;
    java = {
      enable = true;
      package = pkgs.jdk11;
    };
    wireshark = {
      enable = true;
      package = pkgs.wireshark;
    };
  };

  # Enable anti-aliasing in Java
  environment.variables._JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=gasp";

  virtualisation = {
    libvirtd.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
    };
  };

  # Added user to groups
  users.users.${username}.extraGroups = [ "podman" "wireshark" ];
}

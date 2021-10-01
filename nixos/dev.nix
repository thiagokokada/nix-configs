{ pkgs, config, ... }:
let
  inherit (config.meta) username;
in
{
  environment.systemPackages = with pkgs; [
    docker-compose
    gnome3.gnome-boxes
    python3
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

  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;

  # Added user to groups
  users.users.${username}.extraGroups = [ "docker" "wireshark" ];
}

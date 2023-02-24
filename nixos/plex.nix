{ config, lib, pkgs, ... }:

let
  inherit (config.meta) username;
  archive = "/mnt/archive/${username}";
in
with config.users.users.${username}; {
  # Increase number of directories that Linux can monitor for Plex
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 262144;
  };

  # Enable Plex Media Server
  services.plex = {
    enable = true;
    openFirewall = true;
    group = group;
    package = pkgs.plex;
  };

  systemd.tmpfiles.rules = [
    "d ${archive}/Others 0775 ${username} ${group}"
    "d ${archive}/Musics 0775 ${username} ${group}"
    "d ${archive}/Photos 0775 ${username} ${group}"
    "d ${archive}/Videos 0775 ${username} ${group}"
  ];
}

{ config, lib, pkgs, ... }:

let
  inherit (config.meta) username;
  inherit (config.device) archiveDir;
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
    "d ${archiveDir}/Others 0775 ${username} ${group}"
    "d ${archiveDir}/Musics 0775 ${username} ${group}"
    "d ${archiveDir}/Photos 0775 ${username} ${group}"
    "d ${archiveDir}/Videos 0775 ${username} ${group}"
  ];
}

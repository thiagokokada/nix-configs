{ config, lib, pkgs, ... }:

let
  inherit (config.meta) username;
  inherit (config.device) mediaDir;
in
with config.users.users.${username}; {
  options.nixos.server.plex.enable = lib.mkEnableOption "Plex config";

  config = lib.mkIf config.nixos.server.plex.enable {
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
      "d ${mediaDir}/Other 2775 ${username} ${group}"
      "d ${mediaDir}/Music 2775 ${username} ${group}"
      "d ${mediaDir}/Photos 2775 ${username} ${group}"
      "d ${mediaDir}/Videos 2775 ${username} ${group}"
    ];
  };
}

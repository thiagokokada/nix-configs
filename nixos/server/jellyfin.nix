{ config, lib, ... }:

let
  inherit (config.meta) username;
  inherit (config.device) mediaDir;
in
with config.users.users.${username}; {
  options.nixos.server.jellyfin.enable = lib.mkEnableOption "Jellyfin config";

  config = lib.mkIf config.nixos.server.jellyfin.enable {
    # Enable Jellyfin
    services.jellyfin = {
      enable = true;
      openFirewall = true;
      inherit group;
    };

    security.acme.defaults.reloadServices = [ "jellyfin.service" ];

    systemd.tmpfiles.rules = [
      "d ${mediaDir}/Other 2775 ${username} ${group}"
      "d ${mediaDir}/Music 2775 ${username} ${group}"
      "d ${mediaDir}/Photos 2775 ${username} ${group}"
      "d ${mediaDir}/Videos 2775 ${username} ${group}"
    ];
  };
}

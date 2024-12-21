{ config, lib, ... }:

let
  inherit (config.mainUser) username;
  inherit (config.device.media) directory;
in
with config.users.users.${username};
{
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
      "d ${directory}/Other 2775 ${username} ${group}"
      "d ${directory}/Music 2775 ${username} ${group}"
      "d ${directory}/Photos 2775 ${username} ${group}"
      "d ${directory}/Videos 2775 ${username} ${group}"
    ];
  };
}

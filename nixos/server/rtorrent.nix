{ config, lib, pkgs, ... }:

let
  inherit (config.device) mediaDir;
  inherit (config.meta) username;
in
{
  options.nixos.server.rtorrent.enable = lib.mkEnableOption "rTorrent config";

  config = with config.users.users.${username};
    lib.mkIf config.nixos.server.rtorrent.enable {
      environment.systemPackages = with pkgs; [ rtorrent ];

      services.rtorrent = {
        enable = true;
        downloadDir = "${mediaDir}/Downloads";
        user = username;
        group = group;
        port = 60001;
        openFirewall = true;
        configText = ''
          # Enable the default ratio group.
          ratio.enable=

          # Change the limits, the defaults should be sufficient.
          ratio.min.set=100
          ratio.max.set=300
          ratio.upload.set=500M

          # Watch directory
          schedule2 = watch_directory,5,5,load.start="${home}/Torrents/*.torrent"
          schedule2 = untied_directory,5,5,stop_untied=
        '';
      };

      systemd.services = {
        rtorrent.serviceConfig.Restart = lib.mkForce "always";
        flood = {
          description = "A web UI for rTorrent with a Node.js backend and React frontend.";
          after = [ "rtorrent.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            User = username;
            Group = group;
            Type = "simple";
            Restart = "always";
            ExecStart = "${pkgs.nodePackages.flood}/bin/flood";
          };
        };
      };

      systemd.tmpfiles.rules = [
        "d ${mediaDir}/Downloads 0775 ${username} ${group}"
      ];
    };
}

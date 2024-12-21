{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.device.media) directory;
  inherit (config.mainUser) username;
  cfg = config.nixos.server.rtorrent;
in
{
  options.nixos.server.rtorrent = {
    enable = lib.mkEnableOption "rTorrent config";
    ratio = {
      enable = lib.mkEnableOption "ratio control";
      min = lib.mkOption {
        type = lib.types.int;
        description = "Minimum ratio (if size is reached).";
        default = 200;
      };
      max = lib.mkOption {
        description = "Maximum ratio (if size is not reached).";
        type = lib.types.int;
        default = 300;
      };
      size = lib.mkOption {
        description = "Upload size that should be reached.";
        type = lib.types.str;
        default = "500M";
      };
    };
    flood.enable = lib.mkEnableOption "Flood UI" // {
      default = true;
    };
  };

  config =
    with config.users.users.${username};
    lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [ rtorrent ];

      services = {
        flood = {
          inherit (cfg.flood) enable;
          host = "::";
          openFirewall = true;
          extraArgs = [ "--rtsocket=${config.services.rtorrent.rpcSocket}" ];
        };
        rtorrent = {
          inherit (cfg) enable;
          inherit group;
          downloadDir = "${directory}/Downloads";
          user = username;
          port = 60001;
          openFirewall = true;
          configText = ''
            ${lib.optionalString cfg.ratio.enable ''
              # Enable the default ratio group.
              ratio.enable=

              # Change the limits, the defaults should be sufficient.
              ratio.min.set=${toString cfg.ratio.min}
              ratio.max.set=${toString cfg.ratio.max}
              ratio.upload.set=${cfg.ratio.size}
            ''}

            # Watch directory
            schedule2 = watch_directory,5,5,load.start="${directory}/Torrents/*.torrent"
            schedule2 = untied_directory,5,5,stop_untied=

            # Disable when diskspace is low
            schedule2 = monitor_diskspace, 15, 60, ((close_low_diskspace, 1000M))

            # Set umask for download files
            system.umask.set = 0002
          '';
        };
      };

      systemd.services = {
        flood.serviceConfig = {
          SupplementaryGroups = [ group ];
        };
      };

      systemd.tmpfiles.rules = [
        "d ${directory}/Downloads 2775 ${username} ${group}"
        "d ${directory}/Torrents 2775 ${username} ${group}"
      ];
    };
}

{ config, lib, pkgs, ... }:

let
  inherit (config.device) mediaDir;
  inherit (config.meta) username;
  cfg = config.nixos.server.rtorrent;
in
{
  options.nixos.server.rtorrent = {
    enable = lib.mkEnableOption "rTorrent config";
    flood = {
      enable = lib.mkDefaultOption "Flood UI";
      port = lib.mkOption {
        type = lib.types.int;
        description = "Port to bind webserver";
        default = 3000;
      };
      host = lib.mkOption {
        type = lib.types.str;
        description = "Host to bind webserver";
        default = "0.0.0.0";
      };
    };
  };

  config = with config.users.users.${username};
    lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [ rtorrent ];

      services.rtorrent = {
        enable = true;
        downloadDir = "${mediaDir}/Downloads";
        user = username;
        inherit group;
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
          schedule2 = watch_directory,5,5,load.start="${mediaDir}/Torrents/*.torrent"
          schedule2 = untied_directory,5,5,stop_untied=

          # Disable when diskspace is low
          schedule2 = monitor_diskspace, 15, 60, ((close_low_diskspace, 1000M))

          # Set umask for download files
          system.umask.set = 0002
        '';
      };

      systemd.services = {
        rtorrent.serviceConfig = {
          CapabilityBoundingSet = "";
          LockPersonality = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateTmp = true;
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          ProtectSystem = "full";
          RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = [ "@system-service" "~@privileged" ];
        };
        flood = lib.mkIf cfg.flood.enable {
          description = "A web UI for rTorrent with a Node.js backend and React frontend.";
          after = [ "rtorrent.service" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            User = username;
            Group = group;
            Type = "simple";
            Restart = "always";
            ExecStart = "${pkgs.nodePackages.flood}/bin/flood --host ${cfg.flood.host} --port ${toString cfg.flood.port}";

            CapabilityBoundingSet = "";
            LockPersonality = true;
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateTmp = true;
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHostname = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectProc = "invisible";
            ProtectSystem = "strict";
            RestrictAddressFamilies = [ "AF_UNIX" "AF_INET" "AF_INET6" ];
            RestrictNamespaces = true;
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SystemCallArchitectures = "native";
            SystemCallFilter = [ "~@privileged" ];
          };
        };
      };

      networking.firewall.allowedTCPPorts = lib.mkIf cfg.flood.enable [
        cfg.flood.port
      ];

      systemd.tmpfiles.rules = [
        "d ${mediaDir}/Downloads 2775 ${username} ${group}"
        "d ${mediaDir}/Torrents 2775 ${username} ${group}"
      ];
    };
}

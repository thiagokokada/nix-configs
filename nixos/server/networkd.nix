{ config, lib, ... }:
let
  cfg = config.nixos.server.networkd;
in
{
  options.nixos.server.networkd = {
    enable = lib.mkEnableOption "systemd-networkd config" // {
      default = config.nixos.server.enable;
    };
    watchdog = {
      enable = lib.mkEnableOption "restart systemd-networkd if target ping fails";
      target = lib.mkOption {
        type = lib.types.str;
        default = "www.google.com";
        description = "Host to be ping'ed";
      };
      onBootSec = lib.mkOption {
        type = lib.types.str;
        default = "1h";
        example = "30m";
        description = ''
          When to run watchdog after the boot.
        '';
      };
      onCalendar = lib.mkOption {
        type = lib.types.str;
        default = "*:0/15";
        example = "hourly";
        description = ''
          When to run watchdog on calendar.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.resolved.enable = true;
    networking.useNetworkd = true;

    systemd = lib.mkIf cfg.watchdog.enable {
      services = {
        systemd-network.partOf = [ "systemd-networkd.service" ];
        systemd-networkd-watchdog = {
          description = "Network watchdog";
          after = [ "network-online.target" ];
          wants = [ "systemd-networkd.service" ];
          script = ''
            /run/wrappers/bin/ping -c ${cfg.watchdog.target}
          '';

          serviceConfig = {
            DynamicUser = true;
            CapabilityBoundingSet = "";
            EnvironmentFile = cfg.environmentFile;
            LockPersonality = true;
            MemoryDenyWriteExecute = true;
            ProtectControlGroups = true;
            ProtectClock = true;
            PrivateDevices = true;
            ProtectHome = true;
            RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
            RestrictNamespaces = true;
            RestrictRealtime = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectSystem = "strict";
            SystemCallFilter = "@system-service";
            Type = "oneshot";
          };
        };

      };

      timers.systemd-networkd-watchdog = {
        timerConfig = {
          OnBootSec = cfg.onBootSec;
          OnCalendar = cfg.onCalendar;
        };
      };
    };
  };
}

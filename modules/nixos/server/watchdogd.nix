{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixos.server.watchdogd;
  ping-watchdog = pkgs.writeShellScriptBin "ping-watchdog" ''
    /run/current-system/sw/bin/ping -c 4 8.8.8.8
  '';
  logDirectory = "/var/lib/misc";
in
{
  options.nixos.server.watchdogd = {
    enable = lib.mkEnableOption "watchdogd config";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ ping-watchdog ];

    services.watchdogd = {
      enable = true;
      settings = {
        "generic /run/current-system/sw/bin/ping-watchdog" = {
          enabled = true;
          interval = 300;
          timeout = 60;
          critical = 1;
        };
        reset-reason.file = "${logDirectory}/watchdogd.state";
      };
    };

    systemd.tmpfiles.rules = [ "d ${logDirectory} 0700" ];
  };
}

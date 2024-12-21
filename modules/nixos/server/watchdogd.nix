{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixos.server.watchdogd;
  ping = pkgs.writeShellScriptBin "ping-watchdog" ''
    /run/current-system/sw/bin/ping -c 4 8.8.8.8
  '';
in
{
  options.nixos.server.watchdogd = {
    enable = lib.mkEnableOption "watchdogd config" // {
      default = config.nixos.server.enable;
    };
    logDirectory = lib.mkOption {
      type = lib.types.path;
      description = "Log directory";
      default = "/var/lib/misc";
    };
  };

  config = lib.mkIf cfg.enable {
    # Since we are using unsafeDiscardStringContext, we need to reference this
    # path somewhere else, otherwise the script may be GC'd
    environment.systemPackages = [ ping ];

    services.watchdogd = {
      enable = true;
      settings = {
        # Strings with context are not supported as keys in attrsets
        "generic ${builtins.unsafeDiscardStringContext ping}/bin/ping-watchdog" = {
          enabled = true;
          interval = 300;
          timeout = 60;
          critical = 1;
        };
        reset-reason.file = "${cfg.logDirectory}/watchdogd.state";
      };
    };

    systemd.tmpfiles.rules = [ "d ${cfg.logDirectory} 0700" ];
  };
}

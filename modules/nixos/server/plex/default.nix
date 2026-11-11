{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.nixos.home) username;
  inherit (config.device.media) directory;
  inherit (config.services.plex) user;
  plexPreferences = "/var/lib/plex/Plex Media Server/Preferences.xml";
  plexPreferencesBackup = "${plexPreferences}.bak";
  inhibitorPython = pkgs.python3.withPackages (ps: [ ps.dbus-python ]);
  inhibitorScript = pkgs.writeText "plex-inhibit-sleep.py" (
    builtins.readFile ./plex-inhibit-sleep.py
  );
in
with config.users.users.${username};
{
  options.nixos.server.plex.enable = lib.mkEnableOption "Plex config";

  config = lib.mkIf config.nixos.server.plex.enable {
    # Increase number of directories that Linux can monitor for Plex
    boot.kernel.sysctl = {
      "fs.inotify.max_user_watches" = 524288;
    };

    # Enable Plex Media Server
    services.plex = {
      enable = true;
      openFirewall = true;
      accelerationDevices = [ "*" ];
      inherit group;
    };

    systemd.services."plex-preferences-guard" = {
      description = "Validate, backup, and recover Plex Preferences.xml";
      before = [ "plex.service" ];
      after = [ "local-fs.target" ];
      path = [ pkgs.coreutils ];
      serviceConfig = {
        Type = "oneshot";
      };
      script = ''
        set -eu

        preferences='${plexPreferences}'
        backup='${plexPreferencesBackup}'

        if [ -s "$preferences" ]; then
          cp -f "$preferences" "$backup"
          chown ${user}:${group} "$backup"
          chmod 0600 "$backup"
          exit 0
        fi

        if [ -e "$preferences" ] && [ -s "$backup" ]; then
          cp -f "$backup" "$preferences"
          chown ${user}:${group} "$preferences"
          chmod 0600 "$preferences"
          exit 0
        fi

        if [ -e "$preferences" ]; then
          echo "Plex Preferences.xml is empty and no valid backup exists at $backup" >&2
          exit 1
        fi
      '';
    };

    systemd.services.plex = {
      requires = [ "plex-preferences-guard.service" ];
      after = [ "plex-preferences-guard.service" ];
    };

    systemd.services.plex-inhibit-sleep = {
      description = "Inhibit sleep during Plex playback";
      wantedBy = [
        "multi-user.target"
        "plex.service"
      ];
      bindsTo = [ "plex.service" ];
      after = [
        "plex.service"
        "systemd-logind.service"
      ];
      wants = [ "systemd-logind.service" ];
      serviceConfig = {
        ExecStart = "${inhibitorPython}/bin/python ${inhibitorScript} ${lib.escapeShellArg plexPreferences}";
        Restart = "on-failure";
        RestartSec = 15;
        # Root can read Plex's private token and acquire logind inhibitors
        # without an interactive polkit authorization.
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        CapabilityBoundingSet = [ "CAP_DAC_READ_SEARCH" ];
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_INET"
        ];
      };
    };

    systemd.tmpfiles.rules = [
      "d ${directory}/Other 2775 ${username} ${group}"
      "d ${directory}/Music 2775 ${username} ${group}"
      "d ${directory}/Photos 2775 ${username} ${group}"
      "d ${directory}/Videos 2775 ${username} ${group}"
    ];
  };
}

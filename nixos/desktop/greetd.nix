{ config, lib, pkgs, ... }:

{
  options.nixos.desktop.greetd.enable = lib.mkDefaultOption "greetd config";

  config = lib.mkIf config.nixos.desktop.greetd.enable {
    boot = {
      consoleLogLevel = 3;
      kernelParams = [
        # Force kernel log in tty1, otherwise it will override greetd
        "console=tty1"
      ];
    };

    services = {
      # Configure greetd, a lightweight session manager
      greetd = {
        enable = true;
        settings = rec {
          initial_session =
            let
              genSessionsFor = path:
                lib.concatStringsSep ":"
                  (map (s: "${s}/${path}")
                    config.services.xserver.displayManager.sessionPackages);
            in
            {
              command = lib.concatStringsSep " " [
                "${pkgs.greetd.tuigreet}/bin/tuigreet"
                "--remember"
                "--remember-session"
                "--time"
                "--cmd sx"
                "--sessions"
                # We can't know if the sessions inside sessionPackages are for
                # X or Wayland, so add both to path
                "${genSessionsFor "share/xsessions"}:${genSessionsFor "share/wayland-sessions"}"
              ];
              user = "greeter";
            };
          default_session = initial_session;
        };
        vt = 7;
      };
    };

    # https://github.com/apognu/tuigreet/issues/76
    systemd.tmpfiles.rules = [
      "d /var/cache/tuigreet 700 ${config.services.greetd.settings.initial_session.user} nobody"
    ];
  };
}

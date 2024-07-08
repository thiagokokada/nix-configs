{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.nixos.desktop.greetd.enable = lib.mkEnableOption "greetd config" // {
    default = config.nixos.desktop.enable;
  };

  config = lib.mkIf config.nixos.desktop.greetd.enable {
    boot = {
      consoleLogLevel = lib.mkDefault 3;
      kernelParams = [
        # Force kernel log in tty1, otherwise it will override greetd
        "console=tty1"
      ];
    };

    services = {
      # Configure greetd, a lightweight session manager
      greetd = {
        enable = true;
        settings = {
          default_session =
            let
              genSessionsFor =
                path:
                lib.concatStringsSep ":" (map (s: "${s}/${path}") config.services.displayManager.sessionPackages);
            in
            {
              command = lib.concatStringsSep " " [
                (lib.getExe pkgs.greetd.tuigreet)
                "--remember"
                "--remember-session"
                "--time"
                "--cmd sx"
                "--sessions"
                # We can't know if the sessions inside sessionPackages are for
                # X or Wayland, so add both to path
                "${genSessionsFor "share/xsessions"}:${genSessionsFor "share/wayland-sessions"}"
              ];
            };
        };
        vt = 7;
      };
    };
  };
}

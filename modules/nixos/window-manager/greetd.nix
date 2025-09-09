{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.nixos.window-manager.greetd.enable = lib.mkEnableOption "greetd config" // {
    default = config.nixos.window-manager.enable;
  };

  config = lib.mkIf config.nixos.window-manager.greetd.enable {
    boot.consoleLogLevel = lib.mkDefault 3;

    services = {
      # Configure greetd, a lightweight session manager
      greetd = {
        enable = true;
        settings = {
          default_session =
            let
              inherit (config.services.displayManager.sessionData) desktops;
            in
            {
              command = lib.escapeShellArgs [
                (lib.getExe pkgs.tuigreet)
                "--remember"
                "--remember-session"
                "--time"
                "--sessions"
                "${lib.concatStringsSep ":" (
                  builtins.map (path: "${desktops}/${path}") [
                    "share/xsessions"
                    "share/wayland-sessions"
                  ]
                )}"
              ];
            };
        };
      };
    };
  };
}

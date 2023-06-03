{ config, pkgs, lib, ... }:

{
  boot = {
    consoleLogLevel = 3;
    kernelParams = [
      # Force kernel log in tty1, otherwise it will override greetd
      "console=tty1"
    ];
    plymouth.enable = lib.mkDefault true;
  };

  # Configure the virtual console keymap from the xserver keyboard settings
  console.useXkbConfig = true;

  # Configure special programs (i.e. hardware access)
  programs = {
    dconf.enable = true;
    light.enable = true;
  };

  services = {
    autorandr.enable = true;
    keyd = {
      enable = true;
      settings = {
        main = {
          capslock = "overload(control, esc)";
        };
        shift = {
          leftshift = "capslock";
          rightshift = "capslock";
        };
      };
    };
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

    xserver = {
      enable = true;

      # Enable sx, a lightweight startx alternative
      displayManager.sx.enable = true;

      # Enable libinput
      libinput = {
        enable = true;
        touchpad = {
          naturalScrolling = true;
          tapping = true;
        };
        mouse = {
          accelProfile = "flat";
        };
      };
    };
  };

  # https://github.com/apognu/tuigreet/issues/76
  systemd.tmpfiles.rules = [
    "d /var/cache/tuigreet 700 ${config.services.greetd.settings.initial_session.user} nobody"
  ];
}

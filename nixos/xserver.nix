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
    # Configure greetd, a lightweight session manager
    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = lib.concatStringsSep " " [
            "${pkgs.greetd.tuigreet}/bin/tuigreet"
            "--remember"
            "--remember-session"
            "--time"
            "--cmd sx"
            "--sessions '${pkgs.sway}/share/wayland-sessions/'"
          ];
          user = "greeter";
        };
        default_session = initial_session;
      };
      vt = 7;
    };

    # Configure monitor hotplug
    udev.extraRules =
      let
        inherit (config.meta) username;
        inherit (config.users.users.${username}) home;
        inherit (config.services.greetd) vt;
      in
      ''
        KERNEL=="card[0-9]*", SUBSYSTEM=="drm", ACTION=="change", ENV{DISPLAY}=":${toString vt}", \
          ENV{HOME}="${home}", ENV{XAUTHORITY}="${home}/.local/share/sx/xauthority", \
          RUN+="${pkgs.change-res}/bin/change-res"
      '';

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

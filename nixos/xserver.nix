{ config, pkgs, lib, ... }:

{
  boot.consoleLogLevel = 3;
  # Force kernel log in tty1, otherwise it will override greetd
  boot.kernelParams = [ "console=tty1" ];

  # Configure the virtual console keymap from the xserver keyboard settings
  console.useXkbConfig = true;

  services = {
    # Configure greetd, a lightweight session manager
    greetd = {
      enable = true;
      settings = rec {
        initial_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sx";
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

  # Configure special programs (i.e. hardware access)
  programs = {
    dconf.enable = true;
    light.enable = true;
  };
}

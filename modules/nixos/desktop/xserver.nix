{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.nixos.desktop.xserver.enable = lib.mkEnableOption "xserver config" // {
    default = config.nixos.desktop.enable;
  };

  config = lib.mkIf config.nixos.desktop.xserver.enable {
    # Configure the virtual console keymap from the xserver keyboard settings
    console.useXkbConfig = true;

    # Configure special programs (i.e. hardware access)
    programs = {
      dconf.enable = true;
      light.enable = true;
    };

    services = {
      # Enable autorandr service, i.e.: sleep.target
      autorandr.enable = true;

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

      xserver = {
        enable = true;

        # Enable sx, a lightweight startx alternative
        displayManager.sx = {
          enable = true;
          addAsSession = true;
        };

        xkb = {
          # X11 keyboard layout
          layout = lib.mkDefault "us";
          variant = lib.mkDefault "intl";
          # Remap Caps Lock to Esc, and use Super+Space to change layouts
          options = lib.mkDefault (
            lib.concatStringsSep "," [
              "caps:escape"
              "grp:win_space_toggle"
            ]
          );
        };
      };
    };

    # Try at least 3 times before considering the service failed
    # Default is 1
    systemd.services.autorandr.startLimitBurst = lib.mkForce 3;
  };
}

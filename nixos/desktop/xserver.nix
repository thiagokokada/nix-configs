{ config, lib, ... }:

{
  options.nixos.desktop.xserver.enable = lib.mkDefaultOption "xserver config";

  config = lib.mkIf config.nixos.desktop.xserver.enable {
    # Configure the virtual console keymap from the xserver keyboard settings
    console.useXkbConfig = true;

    # Configure special programs (i.e. hardware access)
    programs = {
      dconf.enable = true;
      light.enable = true;
    };

    services = {
      autorandr.enable = true;

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
  };
}

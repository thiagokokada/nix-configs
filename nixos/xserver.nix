{ pkgs, ... }:

{
  # Configure the virtual console keymap from the xserver keyboard settings
  console.useXkbConfig = true;

  services = {
    xserver = {
      enable = true;
      # Recommended for modesetting drivers
      useGlamor = true;

      # Configure LightDM
      displayManager = {
        lightdm = {
          enable = true;
          background = pkgs.nixos-artwork.wallpapers.dracula.gnomeFilePath;
          greeters = {
            gtk = {
              enable = true;
              clock-format = "%a %d/%m %H:%M:%S";
              iconTheme = {
                package = pkgs.arc-icon-theme;
                name = "Arc";
              };
              indicators = [ "~clock" "~session" "~power" ];
              theme = {
                package = pkgs.arc-theme;
                name = "Arc-Dark";
              };
            };
          };
        };
      };

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

      # Use i3 as default sessionu;
      displayManager.defaultSession = "none+i3";
      windowManager.i3.enable = true;
    };
  };

  # Configure special programs (i.e. hardware access)
  programs = {
    dconf.enable = true;
    light.enable = true;
  };
}

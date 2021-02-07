{ pkgs, inputs, ... }:

{
  imports = [
    "${inputs.unstable}/nixos/modules/services/x11/hardware/libinput.nix"
  ];

  disabledModules = [
    "services/x11/hardware/libinput.nix"
  ];

  # Configure the virtual console keymap from the xserver keyboard settings
  console.useXkbConfig = true;

  services = {
    # Allow automounting
    gvfs.enable = true;

    # For battery status reporting
    upower.enable = true;

    xserver = {
      enable = true;
      # Recommended for modesetting drivers
      useGlamor = true;

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

      # Remap Caps Lock to Esc, and use Super+Space to change layouts
      xkbOptions = "caps:escape,grp:win_space_toggle";
    };
  };

  # Configure special programs (i.e. hardware access)
  programs = {
    dconf.enable = true;
    light.enable = true;
  };
}

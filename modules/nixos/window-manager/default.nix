{ config, lib, ... }:

{
  imports = [
    ./greetd.nix
    ./wayland.nix
    ./xserver.nix
  ];

  options.nixos.window-manager.enable = lib.mkEnableOption "window-manager config" // {
    default = builtins.any (x: config.device.type == x) [
      "desktop"
      "laptop"
    ];
  };

  config = lib.mkIf config.nixos.window-manager.enable {
    nixos.home.extraModules = {
      home-manager.window-manager.enable = true;
    };

    services = {
      gnome.gnome-keyring.enable = true;
      graphical-desktop.enable = true;
      udisks2.enable = true;
    };

    # Make nm-applet restart in case of failure
    systemd.user.services.nm-applet = {
      serviceConfig = {
        # Use exponential restart
        RestartSteps = 5;
        RestartMaxDelaySec = 10;
        Restart = "on-failure";
      };
    };
  };
}

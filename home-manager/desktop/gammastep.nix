{ config, lib, pkgs, ... }:

{
  options.home-manager.desktop.gammastep.enable = lib.mkEnableOption "gammastep config" // {
    default = config.home-manager.desktop.i3.enable || config.home-manager.desktop.sway.enable;
  };

  config = lib.mkIf config.home-manager.desktop.gammastep.enable {
    services.gammastep = {
      enable = config.device.type != "vm";
      tray = true;
      dawnTime = "6:30-7:30";
      duskTime = "18:30-19:30";
      package = pkgs.gammastep;
      temperature = {
        day = 5700;
        night = 3700;
      };
      settings = {
        general = {
          gamma = 0.8;
          fade = 1;
        };
      };
    };
  };
}

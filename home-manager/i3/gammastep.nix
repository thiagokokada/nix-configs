{ config, lib, pkgs, ... }:

{
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
}

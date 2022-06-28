{ config, lib, pkgs, ... }:

{
  services.picom = {
    enable = config.device.type != "vm";
    backend = "glx";
    experimentalBackends = true;
    fade = true;
    fadeDelta = 2;
    vSync = true;
    extraOptions = ''
      unredir-if-possible = true;
      unredir-if-possible-exclude = [ "name *= 'Firefox'" ];
    '';
  };
}

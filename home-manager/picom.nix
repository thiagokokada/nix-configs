{ config, lib, pkgs, ... }:

{
  services.picom = {
    enable = config.device.type != "vm";
    package = pkgs.unstable.picom-next;
    experimentalBackends = true;
    fade = true;
    fadeDelta = 2;
    backend = "glx";
    vSync = true;
    extraOptions = ''
      unredir-if-possible = true;
      unredir-if-possible-exclude = [ "name *= 'Firefox'" ];
    '';
  };
}

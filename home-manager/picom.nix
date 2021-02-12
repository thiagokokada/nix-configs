{ config, lib, pkgs, ... }:

{
  services.picom = {
    enable = true;
    experimentalBackends = true;
    fade = true;
    fadeDelta = 2;
    backend = "xrender";
    vSync = true;
    extraOptions = ''
      unredir-if-possible = true;
      unredir-if-possible-exclude = [ "name *= 'Firefox'" ];
    '';
  };
}

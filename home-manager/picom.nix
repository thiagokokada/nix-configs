{ config, lib, pkgs, super, self, ... }:

let
  videoDrivers = super.services.xserver.videoDrivers or [ ];
  backend =
    if (builtins.elem "nvidia" videoDrivers)
    then "xrender"
    else "glx";
in
{
  services.picom = {
    inherit backend;
    enable = config.device.type != "vm";
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

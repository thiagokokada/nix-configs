{ super, config, lib, pkgs, ... }:

{
  services.picom = {
    enable = config.device.type != "vm";
    backend = if (lib.isNvidia super) then "glx" else "egl";
    fade = true;
    fadeDelta = 2;
    vSync = true;
    settings = {
      unredir-if-possible = true;
      unredir-if-possible-exclude = [ "name *= 'Firefox'" ];
    };
  };
}

{ super, config, lib, pkgs, ... }:

{
  services.picom = {
    enable = config.device.type != "vm";
    backend = if (pkgs.lib.isNvidia super) then "glx" else "egl";
    fade = true;
    fadeDelta = 2;
    vSync = true;
    settings = {
      unredir-if-possible = true;
      unredir-if-possible-exclude = [ "name *= 'Firefox'" ];
    };
  };
  # Avoid restarting picom indefinitely in Wayland
  systemd.user.services.picom.Service.Restart = lib.mkForce "on-abnormal";
}

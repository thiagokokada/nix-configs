{ config, lib, osConfig, ... }:

{
  services.picom = {
    enable = config.device.type != "vm";
    backend = if (lib.isNvidia osConfig) then "glx" else "egl";
    fade = true;
    fadeDelta = 2;
    vSync = true;
    settings = {
      unredir-if-possible = true;
      unredir-if-possible-exclude = [ "name *= 'Firefox'" ];
      # https://github.com/google/xsecurelock/issues/97#issuecomment-1183086902
      fade-exclude = [ "class_g = 'xsecurelock'" ];
    };
  };
  # Avoid restarting picom indefinitely in Wayland
  systemd.user.services.picom.Service.Restart = lib.mkForce "on-abnormal";
}

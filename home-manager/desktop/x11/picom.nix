{ config, lib, ... }:

{
  options.home-manager.desktop.x11.picom.enable = lib.mkEnableOption "picom config" // {
    default = config.home-manager.desktop.x11.enable;
  };

  config = lib.mkIf config.home-manager.desktop.x11.picom.enable {
    services.picom = {
      enable = true;
      backend = if config.home-manager.desktop.x11.nvidia.enable then "glx" else "egl";
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
  };
}

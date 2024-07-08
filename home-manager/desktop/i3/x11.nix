{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:

{
  options.home-manager.desktop.i3.x11.enable = lib.mkEnableOption "x11 config" // {
    default = config.home-manager.desktop.i3.enable;
  };

  config = lib.mkIf config.home-manager.desktop.i3.x11.enable {
    home.packages = with pkgs; [
      xclip
      xdotool
      xdragon
      xorg.xdpyinfo
      xorg.xhost
      xorg.xkill
      xorg.xset
    ];

    # Compatibility with xinit/sx
    home.file.".xinitrc" = {
      inherit (config.home.file.".xsession") executable text;
    };
    xdg.configFile."sx/sxrc" = {
      inherit (config.home.file.".xsession") executable text;
    };

    xresources.properties = with config.home-manager.desktop.theme.fonts; {
      "Xft.dpi" = toString dpi;
    };

    xsession = {
      enable = true;
      initExtra =
        # NVIDIA sync
        lib.optionalString (osConfig.hardware.nvidia.prime.sync.enable or false) ''
          ${lib.geExe pkgs.xorg.xrandr} --setprovideroutputsource modesetting NVIDIA-0
          ${lib.getExe pkgs.xorg.xrandr} --auto
        ''
        # Reverse PRIME
        + lib.optionalString (osConfig.hardware.nvidia.prime.offload.enable or false) ''
          ${lib.getExe pkgs.xorg.xrandr} --setprovideroutputsource NVIDIA-G0 modesetting
        ''
        # Automatically loads the resolution
        + ''
          ${lib.getExe pkgs.change-res}
        '';
    };
  };
}

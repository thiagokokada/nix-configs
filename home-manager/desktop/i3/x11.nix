{ config, lib, pkgs, osConfig, ... }:

let
  xsession = "${config.home.homeDirectory}/.xsession";
in
{
  options.home-manager.desktop.i3.x11.enable = lib.mkEnableOption "x11 config" // {
    default = config.home-manager.desktop.i3.enable;
  };

  config = lib.mkIf config.home-manager.desktop.i3.x11.enable {
    # Disable keyboard management via HM
    home.keyboard = null;

    # Compatibility with xinit/sx
    home.file.".xinitrc".source = config.lib.file.mkOutOfStoreSymlink xsession;
    xdg.configFile."sx/sxrc".source = config.lib.file.mkOutOfStoreSymlink xsession;

    xresources.properties = with config.theme.fonts; {
      "Xft.dpi" = toString dpi;
    };

    xsession = {
      enable = true;
      initExtra =
        # NVIDIA sync
        lib.optionalString (osConfig.hardware.nvidia.prime.sync.enable or false) ''
          ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource modesetting NVIDIA-0
          ${pkgs.xorg.xrandr}/bin/xrandr --auto
        ''
        # Reverse PRIME
        + lib.optionalString (osConfig.hardware.nvidia.prime.offload.enable or false) ''
          ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource NVIDIA-G0 modesetting
        ''
        # Automatically loads the resolution
        + ''
          ${pkgs.change-res}/bin/change-res
        '';
    };
  };
}

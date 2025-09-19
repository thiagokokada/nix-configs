{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  cfg = config.home-manager.window-manager.x11;
in
{
  imports = [
    ./autorandr
    ./i3
    ./i3status-rust.nix
    ./picom.nix
    ./rofi.nix
    ./screen-locker.nix
    ./wallpaper.nix
  ];

  options.home-manager.window-manager.x11 = {
    enable = lib.mkEnableOption "x11 config" // {
      default = config.home-manager.window-manager.enable;
    };
    nvidia = {
      enable = lib.mkEnableOption "NVIDIA config" // {
        default = builtins.elem "nvidia" (osConfig.services.xserver.videoDrivers or [ ]);
      };
      prime = {
        sync.enable = lib.mkEnableOption "enable NVIDIA prime sync" // {
          default = osConfig.hardware.nvidia.prime.sync.enable or false;
        };
        offload.enable = lib.mkEnableOption "enable NVIDIA prime offload" // {
          default = osConfig.hardware.nvidia.prime.offload.enable or false;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      xclip
      xdotool
      xdragon
      xorg.xdpyinfo
      xorg.xhost
      xorg.xkill
      xorg.xrandr
      xorg.xset
    ];

    # Compatibility with xinit/sx
    home.file.".xinitrc" = {
      inherit (config.home.file.".xsession") executable text;
    };
    xdg.configFile."sx/sxrc" = {
      inherit (config.home.file.".xsession") executable text;
    };

    xresources.properties = {
      "Xft.dpi" = toString config.theme.fonts.dpi;
    };

    xsession = {
      enable = true;
      initExtra =
        let
          xrandr = lib.getExe pkgs.xorg.xrandr;
        in
        lib.concatStringsSep "\n" [
          # NVIDIA sync
          (lib.optionalString cfg.nvidia.prime.sync.enable ''
            ${xrandr} --setprovideroutputsource modesetting NVIDIA-0
            ${xrandr} --auto
          '')
          # Reverse PRIME
          (lib.optionalString cfg.nvidia.prime.offload.enable ''
            ${xrandr} --setprovideroutputsource NVIDIA-G0 modesetting
          '')
        ];
    };
  };
}

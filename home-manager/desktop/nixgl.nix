{
  config,
  lib,
  libEx,
  pkgs,
  flake,
  ...
}:

let
  cfg = config.home-manager.desktop.nixgl;
  nixGLWrapper' =
    pkg:
    libEx.nixGLWrapper pkgs {
      inherit pkg;
      nixGL = cfg.package;
    };
in
{
  options.home-manager.desktop.nixgl = {
    enable = lib.mkEnableOption "nixGL config" // {
      default = config.targets.genericLinux.enable;
    };
    package = lib.mkPackageOption pkgs [
      "nixgl"
      "nixGLMesa"
    ] { };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [ cfg.package ]
      ++ lib.optionals config.home-manager.desktop.firefox.enable [
        # This may "overwrite" some of the personalizations from the
        # home-manager.desktop.firefox module, since the nixGLWrapper is
        # incompatible with it and we are prioritizing the nixGL wrapped binary
        (lib.hiPrio (nixGLWrapper' firefox))
      ];

    # Needs Vapoursynth disabled so we don't wrap the package
    home-manager.desktop.mpv.vapoursynth.enable = false;

    programs = {
      mpv.package = lib.mkForce (nixGLWrapper' pkgs.mpv);
      wezterm.package = lib.mkForce (nixGLWrapper' pkgs.wezterm);
    };
  };
}

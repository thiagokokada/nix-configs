{ config, lib, libEx, pkgs, ... }:

let
  cfg = config.home-manager.desktop.nixgl;
in
{
  options.home-manager.desktop.nixgl = {
    enable = lib.mkEnableOption "nixGL config" // {
      default = config.targets.genericLinux.enable;
    };
    package = lib.mkPackageOption pkgs [ "nixgl" "nixGLMesa" ] { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      cfg.package
    ] ++ lib.optionals config.home-manager.desktop.firefox.enable [
      # This may "overwrite" some of the personalizations from the
      # home-manager.desktop.firefox module, since the nixGLWrapper is
      # incompatible with it and we are prioritizing the nixGL wrapped binary
      (lib.hiPrio (libEx.nixGLWrapper { pkg = firefox; nixGL = cfg.package; }))
    ];

    # Needs Vapoursynth disabled so we don't wrap the package
    home-manager.desktop.mpv.enableVapoursynth = false;

    programs = {
      mpv.package = libEx.nixGLWrapper {
        pkg = pkgs.mpv;
        nixGL = cfg.package;
      };
    };
  };
}

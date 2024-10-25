{
  config,
  lib,
  pkgs,
  flake,
  ...
}:

let
  cfg = config.home-manager.desktop.nixgl;
in
{
  options.home-manager.desktop.nixgl = {
    enable = lib.mkEnableOption "nixGL config" // {
      default = config.targets.genericLinux.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    nixGL = {
      inherit (flake.inputs.nixgl) packages;
    };

    programs = with config.lib.nixGL; {
      firefox.package = lib.mkForce (wrap pkgs.firefox);
      mpv.package = lib.mkForce (wrap pkgs.mpv);
      wezterm.package = lib.mkForce (wrap pkgs.wezterm);
    };
  };
}

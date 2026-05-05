{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.home-manager.cli.gnu;
in
{
  options.home-manager.cli.gnu.enable = lib.mkEnableOption "GNU config";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      coreutils
      diffutils
      findutils
      gawk
      gnugrep
      gnumake
      gnused
      procps
    ];
  };
}

{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.home-manager.desktop.ghostty;
in
{
  options.home-manager.desktop.ghostty = {
    enable = lib.mkEnableOption "Ghostty config" // {
      # default = config.home-manager.desktop.enable || config.home-manager.darwin.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
      settings = {
        theme = "Catppuccin Mocha";
        font-size = if config.home-manager.darwin.enable then 14.0 else 12.0;
        font-family = config.theme.fonts.symbols.name;
      };
    };
  };
}

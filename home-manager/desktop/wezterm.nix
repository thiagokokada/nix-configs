{ config, lib, ... }:

{
  options.home-manager.desktop.wezterm.enable = lib.mkEnableOption "WezTerm config" // {
    default = config.home-manager.desktop.enable;
  };

  config = lib.mkIf config.home-manager.desktop.wezterm.enable {
    programs.wezterm = {
      enable = true;
      extraConfig = with config.home-manager.desktop.theme.fonts.symbols; ''
        return {
          window_background_opacity = 0.9,
          font = wezterm.font("${name}"),
          font_size = 12.0,
          color_scheme = "Tomorrow Night",
          hide_tab_bar_if_only_one_tab = true,
          scrollback_lines = 10000,
          audible_bell = "Disabled",
        }
      '';
    };
  };
}

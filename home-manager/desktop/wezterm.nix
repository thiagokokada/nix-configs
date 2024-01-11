{ config, lib, ... }:

{
  options.home-manager.desktop.wezterm.enable = lib.mkEnableOption "WezTerm config" // {
    default = config.home-manager.desktop.enable;
  };

  config = lib.mkIf config.home-manager.desktop.wezterm.enable {
    programs.wezterm = {
      enable = true;
      colorSchemes = {
        custom = with config.home-manager.desktop.theme.colors; {
          foreground = base05;
          background = base00;
          cursor_bg = base05;
          cursor_border = base05;
          cursor_fg = base00;
          selection_bg = base02;
          selection_fg = base05;
          ansi = [
            base00
            base08
            base0B
            base0A
            base0D
            base0E
            base0C
            base05
          ];
          brights = [
            base02
            base09
            base01
            base03
            base04
            base06
            base0F
            base07
          ];
        };
      };
      extraConfig = with config.home-manager.desktop.theme.fonts.symbols; ''
        return {
          window_background_opacity = 0.9,
          font = wezterm.font("${name}"),
          font_size = 12.0,
          color_scheme = "custom",
          hide_tab_bar_if_only_one_tab = true,
          scrollback_lines = 10000,
          audible_bell = "Disabled",
        }
      '';
    };
  };
}

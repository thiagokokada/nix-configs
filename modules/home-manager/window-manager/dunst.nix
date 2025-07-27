{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.home-manager.window-manager.dunst.enable = lib.mkEnableOption "dunst config" // {
    default = config.home-manager.window-manager.enable;
  };

  config = lib.mkIf config.home-manager.window-manager.dunst.enable {
    home.packages = with pkgs; [ dunst ];

    services.dunst = {
      enable = true;
      iconTheme = with config.gtk.iconTheme; {
        inherit name package;
      };
      settings =
        with config.theme.colors;
        let
          theme = {
            background = base00;
            foreground = base05;
          };
        in
        {
          global = {
            font = "${config.theme.fonts.gui.name} 8";
            markup = true;
            format = "<b>%s</b>\\n%b";
            sort = true;
            indicate_hidden = true;
            alignment = "left";
            show_age_threshold = 60;
            word_wrap = true;
            ignore_newline = false;
            width = "(0,250)";
            height = "(0,200)";
            origin = "top-right";
            notification_limit = 5;
            transparency = 0;
            idle_threshold = 120;
            follow = "mouse";
            sticky_history = true;
            line_height = 0;
            padding = 8;
            horizontal_padding = 8;
            separator_color = base03;
            frame_width = 1;
            frame_color = base01;
            show_indicators = false;
            icon_position = "left";
            min_icon_size = 48;
            max_icon_size = 48;
          };
          urgency_low = {
            timeout = 5;
          }
          // theme;
          urgency_normal = {
            timeout = 10;
          }
          // theme;
          urgency_high = {
            timeout = 20;
          }
          // theme;
        };
    };
  };
}

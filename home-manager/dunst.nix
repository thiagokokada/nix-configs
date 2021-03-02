{ config, lib, pkgs, ... }:

{
  services.dunst = {
    enable = true;
    iconTheme = with config.gtk.iconTheme; { inherit name package; };
    settings = with config.theme.colors;
      let
        theme = {
          background = base00;
          foreground = base05;
        };
      in
      {
        global = with config.theme.fonts; {
          font = "${gui.name} 8";
          markup = true;
          format = "<b>%s</b>\\n%b";
          sort = true;
          indicate_hidden = true;
          alignment = "left";
          bounce_freq = 0;
          show_age_threshold = 60;
          word_wrap = true;
          ignore_newline = false;
          geometry = "300x5-6+30";
          transparency = 0;
          idle_threshold = 120;
          follow = "mouse";
          sticky_history = true;
          line_height = 0;
          padding = 8;
          horizontal_padding = 8;
          separator_color = base03;
          startup_notification = false;
          frame_width = 1;
          frame_color = base01;
          show_indicators = false;
          icon_position = "left";
          min_icon_size = 64;
          max_icon_size = 64;
        };
        shortcuts = {
          close = "ctrl+space";
          close_all = "ctrl+shift+space";
          history = "ctrl+Escape";
          context = "ctrl+shift+period";
        };
        urgency_low = { timeout = 5; } // theme;
        urgency_normal = { timeout = 10; } // theme;
        urgency_high = { timeout = 20; } // theme;
      };
  };
}

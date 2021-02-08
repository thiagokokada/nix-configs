{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    keybindings = { "ctrl+shift+0" = "change_font_size_all 0"; };
    settings = with config.theme.colors; {
      # Font
      font = "Hack Nerd Font";
      font_size = "12.0";

      # Colors
      foreground = base05;
      background = base00;
      selection_background = base02;
      selection_foreground = base05;
      url_color = base04;
      cursor = base05;
      active_border_color = base01;
      inactive_border_color = base03;
      active_tab_background = base01;
      active_tab_foreground = base04;
      inactive_tab_background = base00;
      inactive_tab_foreground = base05;
      tab_bar_background = base00;
      color0 = base00;
      color1 = base08;
      color2 = base0B;
      color3 = base0A;
      color4 = base0D;
      color5 = base0E;
      color6 = base0C;
      color7 = base05;
      color8 = base03;
      color9 = base09;
      color10 = base01;
      color11 = base02;
      color12 = base04;
      color13 = base06;
      color14 = base0F;
      color15 = base07;

      # Scrollback
      scrollback_lines = 10000;
      scrollback_pager = "${pkgs.page}/bin/page -f";

      # Reduce lag
      sync_to_monitor = false;
      repaint_delay = 10;
      input_delay = 0;

      # Open URLs on click without modifier
      open_url_modifiers = "no_op";

      # Bell
      visual_bell_duration = "0.0";
      enable_audio_bell = false;
      window_alert_bell = true;
      bell_on_tab = true;

      # Misc
      # TODO: Use neovim from module
      # editor = "${config.programs.neovim.finalPackage}/bin/nvim";
      editor = "nvim";
      strip_trailing_spaces = "smart";
      clipboard_control =
        "write-clipboard write-primary read-clipboard read-primary";
      background_opacity = "0.9";

      # Fix for Wayland slow scrolling
      touch_scroll_multiplier = "5.0";
    };
  };

  programs.zsh.initExtra = ''
    # Do not enable those alias in non-kitty terminal
    if [[ "$TERM" == "xterm-kitty" ]]; then
      alias copy="kitty +kitten clipboard";
      alias diffk="kitty +kitten diff";
      alias icat="kitty +kitten icat";
      alias paste="kitty +kitten clipboard --get-clipboard";

      # If set as alias, auto-completion doesn't work
      ssh() { kitty +kitten ssh $@ }
    fi
  '';
}

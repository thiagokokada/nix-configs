{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = config.device.type != "vm";
    keybindings = { "ctrl+shift+0" = "change_font_size all 0"; };
    font = {
      package = (pkgs.nerdfonts.override { fonts = [ "Hack" ]; });
      name = "Hack Nerd Font";
    };
    settings = with config.theme.colors; {
      # Font
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
      color8 = base02;
      color9 = base09;
      color10 = base01;
      color11 = base03;
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

      # Bell
      visual_bell_duration = "0.0";
      enable_audio_bell = false;
      window_alert_on_bell = true;
      bell_on_tab = true;

      # Misc
      editor =
        if config.programs.neovim.enable then
          "${config.programs.neovim.finalPackage}/bin/nvim"
        else
          "${pkgs.neovim}/bin/nvim";
      strip_trailing_spaces = "smart";
      clipboard_control =
        "write-clipboard write-primary read-clipboard read-primary";
      background_opacity = "0.9";

      # Fix for Wayland slow scrolling
      touch_scroll_multiplier = "5.0";

      # For nnn
      allow_remote_control = true;
      listen_on = "unix:/tmp/kitty";
    };
  };

  programs.zsh.initExtra = ''
    # Do not enable those alias in non-kitty terminal
    if [[ "$TERM" == "xterm-kitty" ]]; then
      alias copy="kitty +kitten clipboard"
      alias d="kitty +kitten diff"
      alias icat="kitty +kitten icat"
      alias paste="kitty +kitten clipboard --get-clipboard"
      alias ssh="kitty +kitten ssh $@"
      alias ssh-compat="TERM=xterm-256color ssh"
    fi
  '';
}

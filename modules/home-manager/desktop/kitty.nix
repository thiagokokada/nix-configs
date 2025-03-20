{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.home-manager.desktop.theme) colors fonts;
  cfg = config.home-manager.desktop.kitty;
in
{
  options.home-manager.desktop.kitty = {
    enable = lib.mkEnableOption "Kitty config" // {
      default = config.home-manager.desktop.enable;
    };
    fontSize = lib.mkOption {
      type = lib.types.float;
      description = "Font size.";
      default = 12.0;
    };
    opacity = lib.mkOption {
      type = lib.types.float;
      description = "Background opacity.";
      default = 0.95;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      keybindings = {
        "ctrl+shift+0" = "change_font_size all 0";
      };
      font = {
        inherit (fonts.symbols) package name;
        size = cfg.fontSize;
      };
      settings = with colors; {
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
        scrollback_pager = "${lib.getExe pkgs.page} -f";

        # Reduce lag
        sync_to_monitor = false;
        repaint_delay = 10;
        input_delay = 0;

        # Bell
        visual_bell_duration = "0.0";
        enable_audio_bell = false;
        window_alert_on_bell = true;
        bell_on_tab = true;

        # Tabs
        tab_bar_edge = "top";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";

        # Misc
        inherit (config.home-manager.desktop.default) editor;
        strip_trailing_spaces = "smart";
        clipboard_control = "write-clipboard write-primary read-clipboard read-primary";
        background_opacity = toString cfg.opacity;
        window_padding_width = 5;

        # Fix for Wayland slow scrolling
        touch_scroll_multiplier = "5.0";
      };

      darwinLaunchOptions = [
        "--single-instance"
        (lib.getExe config.programs.zsh.package)
      ];

      shellIntegration.mode = "enabled";
    };

    programs.zsh.initExtra =
      lib.mkIf config.programs.zsh.enable # bash
        ''
          # Do not enable those alias in non-kitty terminal
          if [[ -n "$KITTY_PID" ]]; then
            alias imgcat="kitty +kitten icat"
            alias ssh="kitty +kitten ssh $@"
            alias ssh-compat="TERM=xterm-256color \ssh"
          fi
        '';
  };
}

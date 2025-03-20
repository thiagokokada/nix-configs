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
    useSuperKeybindings = lib.mkEnableOption "keybindings with Super/Command" // {
      default = pkgs.stdenv.isDarwin;
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
      actionAliases = {
        "kitty_scrollback_nvim" = "kitten ${pkgs.kitty-scrollback-nvim}/python/kitty_scrollback_nvim.py";
      };
      keybindings =
        {
          "kitty_mod+t" = "new_tab_with_cwd";
          "kitty_mod+enter" = "new_window_with_cwd";
          "kitty_mod+0" = "change_font_size all 0";
          "kitty_mod+1" = "goto_tab 1";
          "kitty_mod+2" = "goto_tab 2";
          "kitty_mod+3" = "goto_tab 3";
          "kitty_mod+4" = "goto_tab 4";
          "kitty_mod+5" = "goto_tab 5";
          "kitty_mod+6" = "goto_tab 6";
          "kitty_mod+7" = "goto_tab 7";
          "kitty_mod+8" = "goto_tab 8";
          "kitty_mod+9" = "goto_tab 9";
          "kitty_mod+h" = "kitty_scrollback_nvim";
          "kitty_mode+g" = "kitty_scrollback_nvim --config ksb_builtin_last_cmd_output";
        }
        // lib.optionalAttrs cfg.useSuperKeybindings {
          "super+t" = "new_tab_with_cwd";
          "super+enter" = "new_window_with_cwd";
          "super+1" = "goto_tab 1";
          "super+2" = "goto_tab 2";
          "super+3" = "goto_tab 3";
          "super+4" = "goto_tab 4";
          "super+5" = "goto_tab 5";
          "super+6" = "goto_tab 6";
          "super+7" = "goto_tab 7";
          "super+8" = "goto_tab 8";
          "super+9" = "goto_tab 9";
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
        allow_remote_control = "socket-only";
        listen_on = "unix:/tmp/kitty";

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

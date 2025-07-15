{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.home-manager.desktop.kitty;
in
{
  options.home-manager.desktop.kitty = {
    enable = lib.mkEnableOption "Kitty config" // {
      default = config.home-manager.desktop.enable;
    };
    scrollback-nvim.enable = lib.mkEnableOption "kitty-scrollback.nvim" // {
      default = config.home-manager.editor.neovim.enable;
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
        "kitty_scrollback_nvim" =
          lib.optionalString cfg.scrollback-nvim.enable "kitten ${pkgs.vimPlugins.kitty-scrollback-nvim}/python/kitty_scrollback_nvim.py";
      };
      keybindings =
        {
          "kitty_mod+t" = "new_tab_with_cwd";
          "kitty_mod+enter" = "new_window_with_cwd";
          "kitty_mod+backspace" = "change_font_size all 0";
          "kitty_mod+1" = "goto_tab 1";
          "kitty_mod+2" = "goto_tab 2";
          "kitty_mod+3" = "goto_tab 3";
          "kitty_mod+4" = "goto_tab 4";
          "kitty_mod+5" = "goto_tab 5";
          "kitty_mod+6" = "goto_tab 6";
          "kitty_mod+7" = "goto_tab 7";
          "kitty_mod+8" = "goto_tab 8";
          "kitty_mod+9" = "goto_tab 9";
          "kitty_mod+0" = "goto_tab 10";
        }
        // lib.optionalAttrs cfg.scrollback-nvim.enable {
          "kitty_mod+h" = "kitty_scrollback_nvim";
          "kitty_mod+g" = "kitty_scrollback_nvim --config ksb_builtin_last_cmd_output";
        };
      font = {
        inherit (config.theme.fonts.symbols) package name;
        size = cfg.fontSize;
      };
      settings = with config.theme.colors; {
        kitty_mod = lib.mkIf cfg.useSuperKeybindings "super";

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
        tab_powerline_style = "round";
        tab_title_template = "{fmt.fg.red}{bell_symbol}{activity_symbol}{fmt.fg.tab}{tab.last_focused_progress_percent}[{layout_name[:1]}] {index}:{title[:25]}";
        tab_bar_min_tabs = lib.mkIf pkgs.stdenv.isDarwin 1; # always show tabs in macOS

        # Misc
        editor = lib.mkIf config.home-manager.window-manager.enable config.home-manager.window-manager.default.editor;
        enabled_layouts = "tall,fat,grid,horizontal,vertical,stack";
        strip_trailing_spaces = "smart";
        clipboard_control = "write-clipboard write-primary read-clipboard read-primary";
        background_opacity = toString cfg.opacity;
        window_padding_width = 5;
        allow_remote_control = "socket-only";
        listen_on = "unix:/tmp/kitty";

        # Simulate middle-click copy-and-paste, but instead of copying to
        # clipboard it copies to a private buffer
        copy_on_select = "select_buffer";
        "mouse_map middle release ungrabbed paste_from_buffer" = "select_buffer";

        # Fix for Wayland slow scrolling
        touch_scroll_multiplier = lib.mkIf pkgs.stdenv.isLinux "5.0";
      };

      darwinLaunchOptions = [
        "--single-instance"
        # It seems macOS sometimes start a non-login shell, force it here
        "${lib.getExe config.programs.zsh.package} --login"
      ];

      shellIntegration.mode = "enabled";

      themeFile = "Catppuccin-Mocha";
    };

    programs.zsh.initContent =
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

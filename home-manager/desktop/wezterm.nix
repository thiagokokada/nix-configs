{ config, lib, pkgs, ... }:

let
  cfg = config.home-manager.desktop.wezterm;
in
{
  options.home-manager.desktop.wezterm = {
    enable = lib.mkEnableOption "WezTerm config" // {
      default = config.home-manager.desktop.enable;
    };
    fullscreenOnStartup = lib.mkEnableOption "automatically fullscreen on startup" // {
      default = true;
    };
    fontSize = lib.mkOption {
      type = lib.types.float;
      description = "Font size.";
      default = 12.0;
    };
    opacity = lib.mkOption {
      type = lib.types.float;
      description = "Background opacity.";
      default = 0.9;
    };
    scrollbackLines = lib.mkOption {
      type = lib.types.int;
      description = "Scrollback buffer lines. ~100000 is the limit (because of I60R/page).";
      default = 100000;
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      wezterm = {
        enable = true;
        extraConfig =
          let
            inherit (config.home-manager.desktop.theme) fonts colors;
          in
          with colors; /* lua */''
            local act = wezterm.action
            local config = wezterm.config_builder()
            local scrollback_lines = ${toString cfg.scrollbackLines}

            wezterm.on('trigger-editor-with-visible-text', function(window, pane)
              -- Retrieve the current viewport's text.
              --
              -- Note: You could also pass an optional number of lines (eg: 2000) to
              -- retrieve that number of lines starting from the bottom of the viewport.
              local viewport_text = pane:get_lines_as_escapes(scrollback_lines)

              -- Create a temporary file to pass to vim
              local name = os.tmpname()
              local f = io.open(name, 'w+')
              f:write(viewport_text)
              f:flush()
              f:close()

              -- Open a new tab running editor and tell it to open the file
              window:perform_action(
                act.SpawnCommandInNewTab {
                  args = {
                    '${pkgs.writeShellScript "scrollback-buffer-viewer" ''
                      cleanup() { rm -f "$1"; }
                      trap cleanup EXIT
                      ${lib.getExe' pkgs.page "page"} -f < "$1"
                    ''}',
                    name,
                  },
                },
                pane
              )
            end)

            ${lib.optionalString cfg.fullscreenOnStartup /* lua */ ''
              local mux = wezterm.mux
              -- Automatically maximize window on startup
              wezterm.on("gui-startup", function()
                local tab, pane, window = mux.spawn_window{}
                window:gui_window():maximize()
              end)
            ''}

            config.audible_bell = "Disabled"
            config.visual_bell = {
              fade_in_duration_ms = 100,
              fade_out_duration_ms = 100,
              target = 'CursorColor',
            }
            config.color_scheme = "Builtin Pastel Dark"
            config.enable_kitty_keyboard = true
            config.font = wezterm.font("${fonts.symbols.name}")
            config.font_size = ${toString cfg.fontSize}
            config.hide_tab_bar_if_only_one_tab = true
            config.scrollback_lines = scrollback_lines
            config.window_background_opacity = ${toString cfg.opacity}
            config.colors = {
              foreground = "${base05}",
              background = "${base00}",
              cursor_bg = "${base05}",
              cursor_border = "${base05}",
              cursor_fg = "${base00}",
              selection_bg = "${base02}",
              selection_fg = "${base05}",
            };
            config.keys = {
              {
                key = 'H',
                mods = 'CTRL|SHIFT',
                action = act.EmitEvent 'trigger-editor-with-visible-text',
              },
              -- Clears the scrollback and viewport, and then sends CTRL-L to ask the
              -- shell to redraw its prompt
              {
                key = 'K',
                mods = 'CTRL|SHIFT',
                action = act.Multiple {
                  act.ClearScrollback 'ScrollbackAndViewport',
                  act.SendKey { key = 'L', mods = 'CTRL' },
                },
              },
            }
            config.mouse_bindings = {
              -- Change the default click behavior so that it only selects
              -- text and doesn't open hyperlinks
              {
                event = { Up = { streak = 1, button = 'Left' } },
                mods = 'NONE',
                action = act.CompleteSelection 'ClipboardAndPrimarySelection',
              },
              -- Bind 'Up' event of CTRL-Click to open hyperlinks
              {
                event = { Up = { streak = 1, button = 'Left' } },
                mods = 'CTRL',
                action = act.OpenLinkAtMouseCursor,
              },
              -- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
              {
                event = { Down = { streak = 1, button = 'Left' } },
                mods = 'CTRL',
                action = act.Nop,
              },
              -- Scrolling up while holding CTRL increases the font size
              {
                event = { Down = { streak = 1, button = { WheelUp = 1 } } },
                mods = 'CTRL',
                action = act.IncreaseFontSize,
              },

              -- Scrolling down while holding CTRL decreases the font size
              {
                event = { Down = { streak = 1, button = { WheelDown = 1 } } },
                mods = 'CTRL',
                action = act.DecreaseFontSize,
              },
            }

            return config
          '';
      };

      zsh.initExtra = lib.mkIf config.programs.zsh.enable /* bash */ ''
        # Do not enable those alias in non-wezterm terminal
        if [[ -n "$WEZTERM_EXECUTABLE_DIR" ]]; then
          alias imgcat="$WEZTERM_EXECUTABLE_DIR/bin/wezterm imgcat"
        fi
      '';
    };
  };
}

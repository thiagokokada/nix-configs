{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.home-manager.desktop.ghostty;
  ghosttyMod = if cfg.useSuperKeybindings then "super" else "ctrl+shift";
  fontFamily =
    if lib.isList config.theme.fonts.symbols.name then
      builtins.head config.theme.fonts.symbols.name
    else
      config.theme.fonts.symbols.name;
in
{
  options.home-manager.desktop.ghostty = {
    enable = lib.mkEnableOption "Ghostty config" // {
      default = config.home-manager.desktop.enable || config.home-manager.darwin.enable;
    };
    useSuperKeybindings = lib.mkEnableOption "keybindings with Super/Command" // {
      default = config.home-manager.darwin.enable;
    };
    fontSize = lib.mkOption {
      type = lib.types.float;
      description = "Font size.";
      default = if config.home-manager.darwin.enable then 14.0 else 12.0;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optional (
      config.theme.fonts.symbols.package != null
    ) config.theme.fonts.symbols.package;

    programs.ghostty = {
      enable = true;
      enableZshIntegration = config.programs.zsh.enable;
      package = lib.mkDefault (
        if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty
      );
      settings =
        with config.theme.colors;
        {
          theme = "Catppuccin Mocha";
          foreground = base05;
          background = base00;
          selection-background = base02;
          selection-foreground = base05;
          cursor-color = base05;
          split-divider-color = base01;
          font-family = fontFamily;
          font-size = cfg.fontSize;

          confirm-close-surface = false;
          copy-on-select = "clipboard";
          scrollback-limit = 10000;

          window-padding-x = 5;
          window-padding-y = 5;
          window-inherit-working-directory = true;
          tab-inherit-working-directory = true;
          split-inherit-working-directory = true;
          window-inherit-font-size = true;
          window-show-tab-bar = "auto";
          maximize = true;

          link-previews = true;

          keybind = [
            "${ghosttyMod}+t=new_tab"
            "${ghosttyMod}+enter=new_window"
            "${ghosttyMod}+backspace=reset_font_size"
            "${ghosttyMod}+1=goto_tab:1"
            "${ghosttyMod}+2=goto_tab:2"
            "${ghosttyMod}+3=goto_tab:3"
            "${ghosttyMod}+4=goto_tab:4"
            "${ghosttyMod}+5=goto_tab:5"
            "${ghosttyMod}+6=goto_tab:6"
            "${ghosttyMod}+7=goto_tab:7"
            "${ghosttyMod}+8=goto_tab:8"
            "${ghosttyMod}+9=goto_tab:9"
            "${ghosttyMod}+0=goto_tab:10"
          ];
        }
        // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
          gtk-custom-css = toString (
            pkgs.writeText "ghostty-linux-tabs.css"
              # css
              ''
                /* Ghostty GTK tabs on top: shrink from the bottom, don't push into the titlebar. */
                tabbar {
                  margin-top: 0;
                  margin-bottom: -16px;
                }

                tabbar tabbox {
                  transform: translateY(-8px);
                }

                tabbar tabbox tab {
                  min-height: 20px;
                }

                tabbar tabbox tab:selected,
                tabbar tabbox tab:hover {
                  margin-top: 4px;
                  margin-bottom: 4px;
                }

                tabbar tabbox button,
                windowcontrols button {
                  min-height: 20px;
                }
              ''
          );
          window-titlebar-background = base01;
          window-titlebar-foreground = base04;
        }
        // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
          font-thicken = true;
          font-thicken-strength = 100;
          macos-titlebar-style = "tabs";
        };
    };
  };
}

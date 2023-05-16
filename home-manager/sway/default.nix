{ config, lib, pkgs, super, ... }:
let
  # Aliases
  alt = "Mod1";
  modifier = "Mod4";

  commonOptions =
    let
      dunstctl = "${pkgs.dunst}/bin/dunstctl";
      screenShotName = with config.xdg.userDirs;
        "${pictures}/$(${pkgs.coreutils}/bin/date +%Y-%m-%d_%H-%M-%S)-screenshot.png";
    in
    import ../i3/common.nix rec {
      inherit config lib modifier alt;
      browser = "firefox";
      fileManager = "${terminal} ${config.programs.nnn.finalPackage}/bin/nnn -a -P p";
      statusCommand = with config;
        "${programs.i3status-rust.package}/bin/i3status-rs ${xdg.configHome}/i3status-rust/config-sway.toml";
      menu =
        "${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --dmenu='${pkgs.wofi}/bin/wofi --show drun'";
      # light needs to be installed in system, so not defining a path here
      light = "light";
      pamixer = "${pkgs.pamixer}/bin/pamixer";
      playerctl = "${pkgs.playerctl}/bin/playerctl";
      terminal = "${pkgs.kitty}/bin/kitty";

      fullScreenShot = ''
        ${pkgs.grim}/bin/grim "${screenShotName}" && \
        ${pkgs.libnotify}/bin/notify-send -u normal -t 5000 'Full screenshot taken'
      '';
      areaScreenShot = ''
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "${screenShotName}" && \
        ${pkgs.libnotify}/bin/notify-send -u normal -t 5000 'Area screenshot taken'
      '';

      extraBindings = {
        "Ctrl+space" = "exec ${dunstctl} close";
        "Ctrl+Shift+space" = "exec ${dunstctl} close-all";
      };

      extraConfig = with config.xsession.pointerCursor; ''
        hide_edge_borders --i3 smart

        # XCURSOR_SIZE
        seat seat0 xcursor_theme ${name} 24
      '';
    };
in
{
  imports = [
    ../i3/gammastep.nix
    ../i3/i3status-rust.nix
    ./kanshi
    ./swayidle.nix
    ./wofi.nix
  ];

  wayland.windowManager.sway = with commonOptions; {
    enable = true;

    inherit extraConfig;

    config = commonOptions.config // {
      startup = [
        { command = "${pkgs.dex}/bin/dex --autostart"; }
      ];

      input = {
        "type:keyboard" = {
          xkb_layout = "us(intl)";
          xkb_options = "grp:win_space_toggle";
        };
        "type:pointer" = { accel_profile = "flat"; };
        "type:touchpad" = {
          drag = "enabled";
          drag_lock = "enabled";
          middle_emulation = "enabled";
          natural_scroll = "enabled";
          scroll_method = "two_finger";
          tap = "enabled";
          tap_button_map = "lmr";
        };
      };

      output = {
        "*" = {
          bg = "${config.theme.wallpaper.path} ${config.theme.wallpaper.scale}";
          # DPI
          scale = (toString (125 / 100.0));
        };
      };
    };

    extraSessionCommands = ''
      export XDG_CURRENT_DESKTOP=sway
      # Firefox
      export MOZ_ENABLE_WAYLAND=1
      # Qt
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      # SDL
      export SDL_VIDEODRIVER=wayland
      # Fix for some Java AWT applications (e.g. Android Studio),
      # use this if they aren't displayed properly:
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';

    systemdIntegration = true;

    wrapperFeatures = {
      base = true;
      gtk = true;
    };

    extraOptions = lib.optionals (pkgs.lib.isNvidia super) [
      "--unsupported-gpu"
    ];
  };

  services.xembed-sni-proxy.enable = true;
  xsession.preferStatusNotifierItems = true;

  home.packages = with pkgs; [
    dex
    mako
    swayidle
    swaylock
    wl-clipboard
    wdisplays
  ];
}

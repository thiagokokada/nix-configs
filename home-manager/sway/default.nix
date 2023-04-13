{ config, lib, pkgs, super, ... }:
let
  # Aliases
  alt = "Mod1";
  modifier = "Mod4";

  commonOptions =
    let
      makoctl = "${pkgs.mako}/bin/makoctl";
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
        "Ctrl+space" = "exec ${makoctl} dismiss";
        "Ctrl+Shift+space" = "exec ${makoctl} dismiss -a";
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
    ./wofi.nix
  ];

  wayland.windowManager.sway = with commonOptions; {
    enable = true;

    inherit extraConfig;

    config = commonOptions.config // {
      startup = [
        { command = "${pkgs.dex}/bin/dex --autostart"; }
        {
          command =
            let
              swayidle = "${pkgs.swayidle}/bin/swayidle";
              swaylock = "${pkgs.swaylock}/bin/swaylock";
              swaymsg = "${pkgs.sway}/bin/swaymsg";
            in
            ''
              ${swayidle} -w \
              timeout 600 '${swaylock} -f -c 000000' \
              timeout 605 '${swaymsg} "output * dpms off"' \
              resume '${swaymsg} "output * dpms on"' \
              before-sleep '${swaylock} -f -c 000000' \
              lock '${swaylock} -f -c 000000'
            '';
        }
      ];

      input = {
        "type:keyboard" = {
          xkb_layout = "us(intl),br";
          xkb_options = "caps:escape,grp:win_space_toggle";
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
          # DPI
          scale = (toString (125 / 100.0));
        };
      };
    };

    extraSessionCommands = ''
      export XDG_CURRENT_DESKTOP=sway
      # Breaks Chromium/Electron
      # export GDK_BACKEND=wayland
      # Firefox
      export MOZ_ENABLE_WAYLAND=1
      # Qt
      export XDG_SESSION_TYPE=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
      # SDL
      export SDL_VIDEODRIVER=wayland
      # Elementary/EFL
      export ECORE_EVAS_ENGINE=wayland_egl
      export ELM_ENGINE=wayland_egl
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

  home.packages = with pkgs; [
    dex
    mako
    swayidle
    swaylock
    wl-clipboard
    wdisplays
  ];
}

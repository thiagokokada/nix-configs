{ config, lib, pkgs, ... }:
let
  # Aliases
  alt = "Mod1";
  modifier = "Mod4";

  commonOptions =
    let
      dunstctl = "${pkgs.dunst}/bin/dunstctl";
      rofi = "${config.programs.rofi.package}/bin/rofi";
      mons = "${pkgs.mons}/bin/mons";
      screenShotName = with config.xdg.userDirs;
        "${pictures}/$(${pkgs.coreutils}/bin/date +%Y-%m-%d_%H-%M-%S)-screenshot.png";
      displayLayoutMode =
        " : [h]  , [j]  , [k]  , [l]  , [d]uplicate, [m]irror, [s]econd-only, [o]ff";
    in
    import ./i3-common.nix rec {
      inherit config lib modifier alt;

      browser = "firefox";
      fileManager = "${terminal} ${config.programs.nnn.finalPackage}/bin/nnn -a -P p";
      statusCommand = with config;
        "${programs.i3status-rust.package}/bin/i3status-rs ${xdg.configHome}/i3status-rust/config-i3.toml";
      menu = "${rofi} -show drun";
      # light needs to be installed in system, so not defining a path here
      light = "light";
      pamixer = "${pkgs.pamixer}/bin/pamixer";
      playerctl = "${pkgs.playerctl}/bin/playerctl";
      terminal =
        if config.programs.kitty.enable then
          "${pkgs.kitty}/bin/kitty"
        else
          "${pkgs.xterm}/bin/xterm";

      # Screenshots
      fullScreenShot = ''
        ${pkgs.maim}/bin/maim -u "${screenShotName}" && \
        ${pkgs.libnotify}/bin/notify-send -u normal -t 5000 'Full screenshot taken'
      '';
      areaScreenShot = ''
        ${pkgs.maim}/bin/maim -u -s "${screenShotName}" && \
        ${pkgs.libnotify}/bin/notify-send -u normal -t 5000 'Area screenshot taken'
      '';

      extraBindings = {
        "${modifier}+p" = ''mode "${displayLayoutMode}"'';
        "${modifier}+c" =
          "exec ${rofi} -show calc -modi calc -no-show-match -no-sort";
        "${modifier}+Tab" = "exec ${rofi} -show window -modi window";
        "Ctrl+space" = "exec ${dunstctl} close";
        "Ctrl+Shift+space" = "exec ${dunstctl} close-all";
      };

      extraModes = with commonOptions.helpers; {
        ${displayLayoutMode} = (mapDirection {
          leftCmd = "mode default, exec ${mons} -e left";
          downCmd = "mode default, exec ${mons} -e bottom";
          upCmd = "mode default, exec ${mons} -e top";
          rightCmd = "mode default, exec ${mons} -e right";
        }) // {
          d = "mode default, exec ${mons} -d";
          m = "mode default, exec ${mons} -m";
          s = "mode default, exec ${mons} -s";
          o = "mode default, exec ${mons} -o";
          "Escape" = "mode default";
          "Return" = "mode default";
        };
      };

      extraConfig = ''
        # app specific fixes
        # https://github.com/ValveSoftware/steam-for-linux/issues/1040
        for_window [class="^Steam$" title="^Friends$"] floating enable
        for_window [class="^Steam$" title="Steam - News"] floating enable
        for_window [class="^Steam$" title=".* - Chat"] floating enable
        for_window [class="^Steam$" title="^Settings$"] floating enable
        for_window [class="^Steam$" title=".* - event started"] floating enable
        for_window [class="^Steam$" title=".* CD key"] floating enable
        for_window [class="^Steam$" title="^Steam - Self Updater$"] floating enable
        for_window [class="^Steam$" title="^Screenshot Uploader$"] floating enable
        for_window [class="^Steam$" title="^Steam Guard - Computer Authorization Required$"] floating enable
        for_window [title="^Steam Keyboard$"] floating enable
      '';
    };
in
{
  imports = [
    ./dunst.nix
    ./gammastep.nix
    ./i3status-rust.nix
    ./picom.nix
    ./rofi.nix
    ./x11.nix
  ];

  home = {
    # Disable keyboard management via HM
    keyboard = null;

    packages = with pkgs; [
      arandr
      dex
      feh
      ffmpegthumbnailer
      kbdd
      libnotify
      maim
      mons
      playerctl
      wmctrl
      xsecurelock
      xss-lock
    ];
  };

  xsession.windowManager.i3 = with commonOptions; {
    enable = true;

    inherit extraConfig;

    config = commonOptions.config // {
      startup = [
        {
          command = "${pkgs.xorg.xset}/bin/xset s 600 30";
          notification = false;
        }
        {
          command = "${pkgs.mons}/bin/mons -a";
          notification = false;
        }
        {
          command = "${pkgs.dex}/bin/dex --autostart";
          notification = false;
        }
      ];

    };
  };

}

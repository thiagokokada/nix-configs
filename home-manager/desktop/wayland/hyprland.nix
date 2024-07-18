{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.home-manager.desktop.wayland.hyprland;
  # Modifiers
  alt = "ALT";
  ctrl = "CONTROL";
  mod = "SUPER";
  shift = key: "${key}_SHIFT";
in
{
  options.home-manager.desktop.wayland.hyprland.enable = lib.mkEnableOption "Hyprland config" // {
    default = config.home-manager.desktop.wayland.enable;
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ hyprshot ];

    wayland.windowManager.hyprland = {
      enable = true;
      settings =
        let
          hyprctl = lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl";
          # FIXME: use wezterm instead
          # https://github.com/wez/wezterm/issues/5103
          terminal = lib.getExe config.programs.kitty.package;
          menu = lib.getExe config.programs.fuzzel.package;
          browser = lib.getExe config.programs.firefox.package;
          bar = lib.getExe config.programs.waybar.package;
          fileManager = "${terminal} ${lib.getExe config.programs.nnn.finalPackage} -a -P p";
          pamixer = lib.getExe pkgs.pamixer;
          playerctl = lib.getExe pkgs.playerctl;
          dunstctl = lib.getExe' pkgs.dunst "dunstctl";
          light = "light"; # needs to be installed system wide
          fullScreenshot = "${lib.getExe pkgs.hyprshot} -m output -o ${config.xdg.userDirs.pictures}";
          areaScreenshot = "${lib.getExe pkgs.hyprshot} -m region -o ${config.xdg.userDirs.pictures}";
        in
        {
          exec-once = with config.home-manager.desktop.theme.wallpaper; [
            bar
            # For DPI configuration and other Xresources config
            "${lib.getExe pkgs.xorg.xrdb} -merge ${config.xresources.path}"
            "${lib.getExe pkgs.swaybg} -i ${path} -m ${scale}"
          ];
          env = [
            # Cursor
            "XCURSOR_THEME,${toString config.xsession.pointerCursor.name}"
            "XCURSOR_SIZE,${toString config.xsession.pointerCursor.size}"
            # Chrome/Chromium/Electron
            "NIXOS_OZONE_WL,1"
            # SDL
            "SDL_VIDEODRIVER,wayland"
            # Fix for some Java AWT applications (e.g. Android Studio),
            # use this if they aren't displayed properly:
            "_JAVA_AWT_WM_NONREPARENTING,1"
          ];
          # https://github.com/hyprwm/Hyprland/issues/4337
          monitor = ",preferred,auto,${toString (config.home-manager.desktop.theme.fonts.dpi / 100.0)}";
          debug.disable_scale_checks = true;
          general = {
            layout = "dwindle";
            gaps_in = 5;
            gaps_out = 10;
            border_size = 2;
            resize_on_border = false;
            # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
            allow_tearing = false;
          };
          input = {
            kb_layout = "us";
            kb_variant = "intl";
            kb_options = "caps:escape,grp:win_space_toggle";
            accel_profile = "flat";
            follow_mouse = 0;
            sensitivity = 0;
            touchpad = {
              natural_scroll = true;
              middle_button_emulation = true;
              tap-to-click = true;
            };
          };
          animations = {
            enabled = true;
            animation = [
              "workspaces,1,2,default"
              "windows,1,1,default,slide"
              "layers,1,1,default,slide"
              "fade,0"
            ];
          };
          dwindle = {
            pseudotile = true;
            preserve_split = true;
            force_split = 2; # always open new split right/bottom, like i3
          };
          misc = {
            font_family = config.home-manager.desktop.theme.fonts.gui.name;
            disable_hyprland_logo = true;
            # force_default_wallpaper = 2; # hypr-chan!
            key_press_enables_dpms = true;
            mouse_move_enables_dpms = false;
            vfr = true;
            vrr = 2;
          };

          # https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs
          gestures = {
            workspace_swipe = true;
            workspace_swipe_fingers = 4;
          };

          # bind flags
          # l -> locked, will also work when an input inhibitor (e.g. a lockscreen) is active.
          # r -> release, will trigger on release of a key.
          # e -> repeat, will repeat when held.
          # n -> non-consuming, key/mouse events will be passed to the active window in addition to triggering the dispatcher.
          # m -> mouse.
          # t -> transparent, cannot be shadowed by other binds.
          # i -> ignore mods, will ignore modifiers.
          # s -> separate, will arbitrarily combine keys between each mod/key.
          # d -> has description, will allow you to write a description for your bind.
          bind =
            [
              # Main bindings
              "${mod}, RETURN, exec, ${terminal}"
              "${mod}, D, exec, ${menu}"
              "${mod}, N, exec, ${browser}"
              "${mod}, M, exec, ${fileManager}"
              "${mod}, SEMICOLON, togglefloating,"
              "${mod}, V, pseudo,"
              "${mod}, B, togglesplit,"
              "${mod}, F, fullscreen,"
              "${shift mod}, C, exec, ${hyprctl} reload"
              "${shift mod}, Q, killactive,"
              "${alt}, F4, killactive,"

              # Cycle active window
              "${mod}, TAB, cyclenext,"
              "${mod}, TAB, bringactivetotop"

              # Move focus with mainMod + arrow keys
              "${mod}, left, movefocus, l"
              "${mod}, right, movefocus, r"
              "${mod}, up, movefocus, u"
              "${mod}, down, movefocus, d"
              # Move focus with mainMod + vi keys
              "${mod}, H, movefocus, l"
              "${mod}, L, movefocus, r"
              "${mod}, K, movefocus, u"
              "${mod}, J, movefocus, d"

              # Move window with mainMod + arrow keys
              "${shift mod}, left, movewindow, l"
              "${shift mod}, right, movewindow, r"
              "${shift mod}, up, movewindow, u"
              "${shift mod}, down, movewindow, d"
              # Move window with mainMod + vi keys
              "${shift mod}, H, movewindow, l"
              "${shift mod}, L, movewindow, r"
              "${shift mod}, K, movewindow, u"
              "${shift mod}, J, movewindow, d"

              # Scratchpad
              "${shift mod}, MINUS, movetoworkspace, special:magic"
              "${mod}, MINUS, togglespecialworkspace, magic"

              # Scroll through existing workspaces with mainMod + scroll
              "${mod}, mouse_down, workspace, e+1"
              "${mod}, mouse_up, workspace, e-1"

              # Notifications
              "${ctrl}, ESCAPE, exec, ${dunstctl} close"
              "${shift ctrl}, ESCAPE, exec, ${dunstctl} close-all"

              # Screenshots
              ", PRINT, exec, ${fullScreenshot}"
              "${mod}, PRINT, exec, ${areaScreenshot}"
            ]
            ++
            # workspaces
            (
              # binds $mod + [shift +] {1..9,0} to [move to] workspace {1..10}
              with builtins;
              concatLists (
                genList (
                  x:
                  let
                    # workspace 10 is mapped to 0
                    ws = toString (if x == 9 then 0 else x + 1);
                  in
                  [
                    "${mod}, ${ws}, workspace, ${toString (x + 1)}"
                    "${mod} SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
                  ]
                ) 10
              )
            );

          bindm =
            let
              leftButton = "272";
              rightButton = "273";
            in
            [
              "${mod}, mouse:${leftButton}, movewindow"
              "${mod}, mouse:${rightButton}, resizewindow"
            ];

          bindel = [
            # Volume
            ", XF86AudioRaiseVolume, exec, ${pamixer} --set-limit 150 --allow-boost -i 5"
            ", XF86AudioLowerVolume, exec, ${pamixer} --set-limit 150 --allow-boost -d 5"
            # Brightness
            ", XF86MonBrightnessUp, exec, ${light} -A 5%"
            ", XF86MonBrightnessDown, exec, ${light} -U 5%"
          ];

          bindl = [
            # Mute
            ", XF86AudioMute, exec, ${pamixer} --toggle-mute"
            ", XF86AudioMicMute, exec, ${pamixer} --toggle-mute --default-source"
            # Audio control
            ", XF86AudioPlay, exec, ${playerctl} play-pause"
            ", XF86AudioStop, exec, ${playerctl} stop"
            ", XF86AudioNext, exec, ${playerctl} next"
            ", XF86AudioPrev, exec, ${playerctl} previous"
          ];

          windowrulev2 = [
            # Ignore maximize events
            "suppressevent maximize, class:.*"
          ];

          # Disable Xwayland scaling, we will scale X applications manually
          xwayland.force_zero_scaling = true;
        };

      extraConfig =
        let
          displayLayoutSubmap = " : [a]uto, [g]ui";
          powerManagementSubmap = " : Screen [l]ock, [e]xit, [s]uspend, [h]ibernate, [R]eboot, [S]hutdown";
          resizeSubmap = " : [h]  , [j]  , [k]  , [l] ";

          systemctl = "systemctl";
          loginctl = "loginctl";
          wdisplays = lib.getExe pkgs.wdisplays;
        in
        ''
          bind = ${mod}, P, submap, ${displayLayoutSubmap}
          submap = ${displayLayoutSubmap}
          binde = , a, exec, ${systemctl} restart --user kanshi.service
          binde = , a, submap, reset
          binde = , g, exec, ${wdisplays}
          binde = , g, submap, reset
          bind = , ESCAPE, submap, reset
          bind = , RETURN, submap, reset
          submap = reset

          bind = ${mod}, R, submap, ${resizeSubmap}
          submap = ${resizeSubmap}
          binde = , right, resizeactive, 10 0
          binde = , left, resizeactive, -10 0
          binde = , up, resizeactive, 0 -10
          binde = , down, resizeactive, 0 10
          bind = , ESCAPE, submap, reset
          bind = , RETURN, submap, reset
          submap = reset

          bind = ${mod}, ESCAPE, submap, ${powerManagementSubmap}
          submap = ${powerManagementSubmap}
          bind = , L, exec, ${loginctl} lock-session
          bind = , L, submap, reset
          bind = , E, exit
          bind = , S, exec, ${systemctl} suspend
          bind = , S, submap, reset
          bind = , H, exec, ${systemctl} hibernate
          bind = , H, submap, reset
          bind = SHIFT, R, exec, ${systemctl} reboot
          bind = SHIFT, S, exec, ${systemctl} poweroff
          bind = , ESCAPE, submap, reset
          bind = , RETURN, submap, reset
          submap = reset
        '';
    };
  };
}

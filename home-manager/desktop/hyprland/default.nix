{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.home-manager.desktop.hyprland.enable = lib.mkEnableOption "Hyprland config" // {
    default = config.home-manager.desktop.enable;
  };

  config = lib.mkIf config.home-manager.desktop.hyprland.enable {
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
          "$mainMod" = "SUPER";
          "$shiftMod" = "SUPER_SHIFT";
          "$altMod" = "ALT";
          "$control" = "CONTROL";
          exec-once = [ bar ];
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
          # FIXME: errors out for DELL S3423DWC 10CWNH3
          # monitor = ",preferred,auto,${toString (config.home-manager.desktop.theme.fonts.dpi / 100.0)}";
          monitor = ",preferred,auto,1.6";
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
          };
          misc = {
            force_default_wallpaper = 2;
            disable_hyprland_logo = false;
          };
          gestures = {
            workspace_swipe = false;
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
              "$mainMod, RETURN, exec, ${terminal}"
              "$mainMod, D, exec, ${menu}"
              "$mainMod, N, exec, ${browser}"
              "$mainMod, M, exec, ${fileManager}"
              "$mainMod, V, togglefloating,"
              "$mainMod, B, togglesplit,"
              "$shiftMod, C, exec, ${hyprctl} reload"
              "$shiftMod, Q, killactive,"
              "$altMod, F4, killactive,"

              # Cycle active window
              "$mainMod, TAB, cyclenext,"
              "$mainMod, TAB, bringactivetotop"

              # Resize active window
              "$mainMod, EQUAL, resizeactive, 10 10"
              "$mainMod, PLUS, resizeactive, 10 10"
              "$mainMod, MINUS, resizeactive, -10 -10"

              # Move focus with mainMod + arrow keys
              "$mainMod, left, movefocus, l"
              "$mainMod, right, movefocus, r"
              "$mainMod, up, movefocus, u"
              "$mainMod, down, movefocus, d"
              # Move focus with mainMod + vi keys
              "$mainMod, H, movefocus, l"
              "$mainMod, L, movefocus, r"
              "$mainMod, K, movefocus, u"
              "$mainMod, J, movefocus, d"

              # Move window with mainMod + arrow keys
              "$shiftMod, left, movewindow, l"
              "$shiftMod, right, movewindow, r"
              "$shiftMod, up, movewindow, u"
              "$shiftMod, down, movewindow, d"
              # Move window with mainMod + vi keys
              "$shiftMod, H, movewindow, l"
              "$shiftMod, L, movewindow, r"
              "$shiftMod, K, movewindow, u"
              "$shiftMod, J, movewindow, d"

              # Scratchpad
              "$mainMod, S, togglespecialworkspace, magic"
              "$mainMod SHIFT, S, movetoworkspace, special:magic"

              # Scroll through existing workspaces with mainMod + scroll
              "$mainMod, mouse_down, workspace, e+1"
              "$mainMod, mouse_up, workspace, e-1"

              # Notifications
              "$control, ESCAPE, exec, ${dunstctl} close"
              "CONTROL_SHIFT, ESCAPE, exec, ${dunstctl} close-all"

              # Screenshots
              ", PRINT, exec, ${fullScreenshot}"
              "$mainMod, PRINT, exec, ${areaScreenshot}"
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
                    "$mainMod, ${ws}, workspace, ${toString (x + 1)}"
                    "$mainMod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
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
              "$mainMod, mouse:${leftButton}, movewindow"
              "$mainMod, mouse:${rightButton}, resizewindow"
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
          bind = $mainMod, P, submap, ${displayLayoutSubmap}
          submap = ${displayLayoutSubmap}
          binde = , a, exec, ${systemctl} restart --user kanshi.service
          binde = , a, submap, reset
          binde = , g, exec, ${wdisplays}
          binde = , g, submap, reset
          bind = , ESCAPE, submap, reset
          bind = , RETURN, submap, reset
          submap = reset

          bind = $mainMod, R, submap, ${resizeSubmap}
          submap = ${resizeSubmap}
          binde = , right, resizeactive, 10 0
          binde = , left, resizeactive, -10 0
          binde = , up, resizeactive, 0 -10
          binde = , down, resizeactive, 0 10
          bind = , ESCAPE, submap, reset
          bind = , RETURN, submap, reset
          submap = reset

          bind = $mainMod, ESCAPE, submap, ${powerManagementSubmap}
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

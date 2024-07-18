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
          "exec-once" = bar;
          # monitor = ",preferred,auto,${toString (config.home-manager.desktop.theme.fonts.dpi / 100.0)}";
          monitor = ",preferred,auto,1.6";
          general = {
            layout = "dwindle";
          };
          input = {
            kb_layout = "us";
            kb_variant = "intl";
            follow_mouse = 0;
            sensitivity = 0;
            touchpad = {
              natural_scroll = false;
            };
          };
          animations = {
            enabled = true;
            animation = [
              "workspaces,1,2,default"
              "windows,1,1,default,slide"
              "fade,0"
            ];
          };
          dwindle = {
            pseudotile = true;
            preserve_split = true;
          };
          master = {
            new_status = "master";
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
              "$mainMod, RETURN, exec, ${terminal}"
              "$mainMod, Q, killactive,"
              "$altMod, F4, killactive,"
              "$mainMod, D, exec, ${menu}"
              "$mainMod, N, exec, ${browser}"
              "$mainMod, M, exec, ${fileManager}"
              "$mainMod, V, togglefloating,"
              "$mainMod, B, togglesplit,"
              "$shiftMod, Q, exit,"
              "$shiftMod, C, exec, ${hyprctl} reload"

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

              # Example special workspace (scratchpad)
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

          bindm = [
            # Move/resize windows with mainMod + LMB/RMB and dragging
            "$mainMod, mouse:272, movewindow"
            "$mainMod, mouse:273, resizewindow"
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
    };
  };
}

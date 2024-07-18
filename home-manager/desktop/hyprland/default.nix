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
    wayland.windowManager.hyprland = {
      enable = true;
      settings =
        let
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
        in
        {
          "$mainMod" = "SUPER";
          "$superMod" = "SUPER_SHIFT";
          "$altMod" = "ALT";
          "$control" = "CONTROL";
          "$terminal" = terminal;
          "$menu" = menu;
          "$browser" = browser;
          "$filemanager" = fileManager;
          "exec-once" = bar;
          # monitor = ",preferred,auto,${toString (config.home-manager.desktop.theme.fonts.dpi / 100.0)}";
          monitor = ",preferred,auto,1.6";
          general = {
            layout = "dwindle";
          };
          input = {
            kb_layout = "us";
            kb_variant = "intl";
            follow_mouse = 1;
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
          bind = [
            "$mainMod, RETURN, exec, $terminal"
            "$mainMod, Q, killactive,"
            "$altMod, F4, killactive,"
            "$mainMod, D, exec, $menu"
            "$mainMod, N, exec, $browser"
            "$mainMod, M, exec, $filemanager"
            "$mainMod, V, togglefloating,"
            "$mainMod, B, togglesplit,"
            "$superMod, Q, exit,"

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
            "$superMod, left, movewindow, l"
            "$superMod, right, movewindow, r"
            "$superMod, up, movewindow, u"
            "$superMod, down, movewindow, d"
            # Move window with mainMod + vi keys
            "$superMod, H, movewindow, l"
            "$superMod, L, movewindow, r"
            "$superMod, K, movewindow, u"
            "$superMod, J, movewindow, d"

            # Switch workspaces with mainMod + [0-9]
            "$mainMod, 1, workspace, 1"
            "$mainMod, 2, workspace, 2"
            "$mainMod, 3, workspace, 3"
            "$mainMod, 4, workspace, 4"
            "$mainMod, 5, workspace, 5"
            "$mainMod, 6, workspace, 6"
            "$mainMod, 7, workspace, 7"
            "$mainMod, 8, workspace, 8"
            "$mainMod, 9, workspace, 9"
            "$mainMod, 0, workspace, 10"

            # Move active window to a workspace with mainMod + SHIFT + [0-9]
            "$mainMod SHIFT, 1, movetoworkspace, 1"
            "$mainMod SHIFT, 2, movetoworkspace, 2"
            "$mainMod SHIFT, 3, movetoworkspace, 3"
            "$mainMod SHIFT, 4, movetoworkspace, 4"
            "$mainMod SHIFT, 5, movetoworkspace, 5"
            "$mainMod SHIFT, 6, movetoworkspace, 6"
            "$mainMod SHIFT, 7, movetoworkspace, 7"
            "$mainMod SHIFT, 8, movetoworkspace, 8"
            "$mainMod SHIFT, 9, movetoworkspace, 9"
            "$mainMod SHIFT, 0, movetoworkspace, 10"

            # Example special workspace (scratchpad)
            "$mainMod, S, togglespecialworkspace, magic"
            "$mainMod SHIFT, S, movetoworkspace, special:magic"

            # Scroll through existing workspaces with mainMod + scroll
            "$mainMod, mouse_down, workspace, e+1"
            "$mainMod, mouse_up, workspace, e-1"

            "$control, ESCAPE, exec, ${dunstctl} close"
            "SUPER_CONTROL, ESCAPE, exec, ${dunstctl} close-all"
          ];

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

{
  config,
  lib,
  pkgs,
  flake,
  ...
}:

let
  inherit (config.wayland.windowManager.hyprland) finalPackage;
  inherit (flake.inputs.hyprland-go.packages.${pkgs.system}) hyprland-go;

  cfg = config.home-manager.window-manager.wayland.hyprland;
  hyprctl = lib.getExe' finalPackage "hyprctl";
  hyprtabs = lib.getExe' hyprland-go "hyprtabs";

  # Mouse
  leftButton = "272";
  rightButton = "273";

  # Modifiers
  alt = "ALT";
  ctrl = "CONTROL";
  mod = "SUPER";
  shift = key: "${key}_SHIFT";
in
{
  options.home-manager.window-manager.wayland.hyprland.enable =
    lib.mkEnableOption "Hyprland config"
    // {
      default = config.home-manager.window-manager.wayland.enable;
    };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprshot
      hyprpicker
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      # Conflicts with programs.hyprland.withUWSM
      systemd.enable = false;
      settings =
        let
          inherit (config.home-manager.window-manager.default) browser terminal fileManager;
          menu = lib.getExe config.programs.fuzzel.package;
          pamixer = lib.getExe pkgs.pamixer;
          playerctl = lib.getExe pkgs.playerctl;
          dunstctl = lib.getExe' pkgs.dunst "dunstctl";
          light = "light"; # needs to be installed system wide
          fullScreenshot = "${lib.getExe pkgs.hyprshot} -m output -o ${config.xdg.userDirs.pictures}";
          areaScreenshot = "${lib.getExe pkgs.hyprshot} -m region -o ${config.xdg.userDirs.pictures}";
        in
        {
          exec-once = with config.theme.wallpaper; [
            # For DPI configuration and other Xresources config
            "${lib.getExe pkgs.xorg.xrdb} -merge ${config.xresources.path}"
            # Set wallpaper
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
          monitor = ",preferred,auto,${toString (config.theme.fonts.dpi / 100.0)}";
          # https://github.com/hyprwm/Hyprland/issues/4337
          # Resolution should divide cleanly by scale to not trigger check
          # e.g: 3440 / 1.6 = 2150.0 and 1440 / 1.6 = 900.0
          # TODO: add validation
          debug.disable_scale_checks = true;
          general = {
            layout = "master";
            gaps_in = 3;
            gaps_out = 6;
            border_size = 2;
            resize_on_border = true;
            # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
            allow_tearing = false;
          };
          master = {
            allow_small_split = true;
          };
          input =
            let
              inherit (config.home.keyboard) layout variant options;
            in
            {
              kb_layout = lib.mkIf (layout != null) layout;
              kb_variant = lib.mkIf (variant != null) variant;
              kb_options = lib.mkIf (options != [ ]) (lib.concatStringsSep "," options);
              accel_profile = "flat";
              follow_mouse = 0;
              sensitivity = 0;
              touchpad = {
                scroll_factor = 0.675;
                natural_scroll = true;
                middle_button_emulation = true;
                tap-to-click = true;
              };
            };
          device = [
            # Sadly it is not possible to set this in input.touchpad
            # https://github.com/hyprwm/Hyprland/issues/5601
            # Get name with `hyprctl devices`
            {
              name = "synps/2-synaptics-touchpad";
              accel_profile = "adaptive";
            }
            {
              name = "tpps/2-elan-trackpoint";
              accel_profile = "adaptive";
            }
          ];
          animations = {
            enabled = true;
            animation = [
              "workspaces,1,2,default"
              "windows,1,1,default,slide"
              "layers,1,2,default,default"
              "fade,0"
            ];
          };
          misc = {
            font_family = config.theme.fonts.gui.name;
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

          binds = {
            # i3's auto_back_and_forth
            workspace_back_and_forth = true;
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
            # Main bindings
            "${mod}, RETURN, exec, ${terminal}"
            "${mod}, D, exec, ${menu}"
            "${mod}, N, exec, ${browser}"
            "${mod}, M, exec, ${fileManager}"
            "${mod}, SEMICOLON, togglefloating,"
            "${mod}, V, pseudo,"
            "${mod}, B, togglesplit,"
            "${mod}, F, fullscreen,"
            "${mod}, W, exec, ${hyprtabs}"
            "${shift mod}, C, exec, ${hyprctl} reload"
            "${shift mod}, Q, killactive,"
            "${alt}, F4, killactive,"

            # Cycle active window
            "${mod}, TAB, cyclenext,"
            "${mod}, TAB, bringactivetotop"

            # Move inside group (tab) with mod + arrow keys
            "${mod}, left, changegroupactive, b"
            "${mod}, right, changegroupactive, f"
            # Move inside group (tab) with mod + vi keys
            "${mod}, H, changegroupactive, b"
            "${mod}, L, changegroupactive, f"

            # Move focus with mod + arrow keys
            "${mod}, left, movefocus, l"
            "${mod}, right, movefocus, r"
            "${mod}, up, movefocus, u"
            "${mod}, down, movefocus, d"
            # Move focus with mod + vi keys
            "${mod}, H, movefocus, l"
            "${mod}, L, movefocus, r"
            "${mod}, K, movefocus, u"
            "${mod}, J, movefocus, d"

            # Move window with mod + arrow keys
            "${shift mod}, left, movewindoworgroup, l"
            "${shift mod}, right, movewindoworgroup, r"
            "${shift mod}, up, movewindoworgroup, u"
            "${shift mod}, down, movewindoworgroup, d"
            # Move window with mod + vi keys
            "${shift mod}, H, movewindoworgroup, l"
            "${shift mod}, L, movewindoworgroup, r"
            "${shift mod}, K, movewindoworgroup, u"
            "${shift mod}, J, movewindoworgroup, d"

            # Scratchpad
            "${shift mod}, MINUS, movetoworkspace, special:magic"
            "${mod}, MINUS, togglespecialworkspace, magic"

            # Scroll through existing workspaces with mod + scroll
            "${mod}, mouse_down, workspace, e+1"
            "${mod}, mouse_up, workspace, e-1"

            # Notifications
            "${ctrl}, ESCAPE, exec, ${dunstctl} close"
            "${shift ctrl}, ESCAPE, exec, ${dunstctl} close-all"

            # Screenshots
            ", PRINT, exec, ${fullScreenshot}"
            "SHIFT, PRINT, exec, ${areaScreenshot}"
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

          bindm = [
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
            # Fix download/save image windows in Firefox
            "float, class:^(firefox)$, title:.*Save(file|As|Image).*"
            "size 800 600, class:^(firefox)$, title:.*Save(file|As|Image).*"
            "pin, class:^(firefox)$,title:.*Save(file|As|Image).*"
            # PIP in Firefox
            "float, class:^(firefox)$, title:.*Picture-in-Picture.*"
          ];

          xwayland = {
            # Disable Xwayland scaling, we will scale X applications manually
            force_zero_scaling = true;
            # If not using above, generally blurry is better than ugly
            use_nearest_neighbor = false;
          };
        };

      extraConfig =
        let
          displayLayoutSubmap = " : [a]uto, [g]ui";
          powerManagementSubmap = " : Screen [l]ock, [e]xit, [s]uspend, [h]ibernate, [R]eboot, [S]hutdown";
          resizeSubmap = " : [h]  , [j]  , [k]  , [l] ";

          # FIXME: https://github.com/systemd/systemd/issues/6032
          # $ hyprctl dispatch exec "loginctl lock-session &>/tmp/out"
          # $ cat /tmp/out
          # Failed to issue method call: Unknown object '/org/freedesktop/login1/session/auto'.
          systemctl = "systemd-run --user systemctl";
          loginctl = "systemd-run --user loginctl";
          wdisplays = lib.getExe pkgs.wdisplays;
        in
        # hyprlang
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

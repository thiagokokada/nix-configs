{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home-manager.window-manager.wayland.sway;
  # Aliases
  alt = "Mod1";
  modifier = "Mod4";

  terminal-cwd = pkgs.writeShellApplication {
    name = "terminal-cwd";

    runtimeInputs = with pkgs; [
      coreutils
      jq
      procps
      sway
    ];

    text = ''
      set +o errexit
      terminal='${config.home-manager.window-manager.default.terminal}'
      terminal_name="''${terminal##*/}"
      pid="$(swaymsg -t get_tree | jq -e ".. | select(.type? and .focused? and .app_id==\"$terminal_name\") | .pid")"
      if [[ -n "$pid" ]]; then
        ppid="$(pgrep --newest --parent "$pid")"
        exec "$terminal" "$(readlink "/proc/$ppid/cwd" || echo "$HOME")"
      fi
      exec "$terminal"
    '';
  };

  commonOptions =
    let
      screenShotName =
        with config.xdg.userDirs;
        "${pictures}/$(${lib.getExe' pkgs.coreutils "date"} +%Y-%m-%d_%H-%M-%S)-screenshot.png";
      displayLayoutMode = " : [a]uto, [g]ui";
      powerManagementMode = " : Screen [l]ock, [e]xit, [s]uspend, [h]ibernate, [R]eboot, [S]hutdown";
      resizeMode = " : [h]  , [j]  , [k]  , [l] ";
      workspaces = [
        { ws = 1; name = "1:  "; }
        { ws = 2; name = "2:  "; }
        { ws = 3; name = "3:  "; }
        { ws = 4; name = "4:  "; }
        { ws = 5; name = "5:  "; }
        { ws = 6; name = "6:  "; }
        { ws = 7; name = "7:  "; }
        { ws = 8; name = "8:  "; }
        { ws = 9; name = "9:  "; }
        { ws = 0; name = "10:  "; }
      ];
      mapDirection = { prefixKey ? null, leftCmd, downCmd, upCmd, rightCmd }:
        with lib.strings; {
          "${optionalString (prefixKey != null) "${prefixKey}+"}Left" = leftCmd;
          "${optionalString (prefixKey != null) "${prefixKey}+"}Down" = downCmd;
          "${optionalString (prefixKey != null) "${prefixKey}+"}Up" = upCmd;
          "${optionalString (prefixKey != null) "${prefixKey}+"}Right" = rightCmd;
          "${optionalString (prefixKey != null) "${prefixKey}+"}h" = leftCmd;
          "${optionalString (prefixKey != null) "${prefixKey}+"}j" = downCmd;
          "${optionalString (prefixKey != null) "${prefixKey}+"}k" = upCmd;
          "${optionalString (prefixKey != null) "${prefixKey}+"}l" = rightCmd;
        };
      mapDirectionDefault = { prefixKey ? null, prefixCmd }:
        mapDirection {
          inherit prefixKey;
          leftCmd = "${prefixCmd} left";
          downCmd = "${prefixCmd} down";
          upCmd = "${prefixCmd} up";
          rightCmd = "${prefixCmd} right";
        };
      workspaceBindings = { prefixKey, prefixCmd }:
        lib.concatMapStringsSep "\n" ({ ws, name }:
          ''bindsym ${prefixKey}+${builtins.toString ws} ${prefixCmd} "${name}"'') workspaces;
      terminal = lib.getExe terminal-cwd;
      msg = lib.getExe' pkgs.sway "swaymsg";
      fullScreenShot = ''
        ${lib.getExe pkgs.grim} "${screenShotName}" && \
        ${lib.getExe pkgs.libnotify} -u normal -t 5000 'Full screenshot taken'
      '';
      areaScreenShot = ''
        ${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp})" "${screenShotName}" && \
        ${lib.getExe pkgs.libnotify} -u normal -t 5000 'Area screenshot taken'
      '';
      exitMode = { "Escape" = "mode default"; "Return" = "mode default"; };
    in {
      helpers = { inherit mapDirection; };
      config = {
        bars = [ ];
        fonts = with config.theme.fonts; {
          names = lib.flatten [ gui.name icons.name ];
          style = "Regular";
          size = 10.0;
        };
        inherit modifier terminal;
        menu = lib.getExe config.programs.fuzzel.package;
        colors = with config.theme.colors; {
          background = base07;
          focused = { background = base0D; border = base0D; childBorder = base0C; indicator = base0D; text = base00; };
          focusedInactive = { background = base01; border = base01; childBorder = base01; indicator = base03; text = base05; };
          placeholder = { background = base00; border = base00; childBorder = base00; indicator = base00; text = base05; };
          unfocused = { background = base00; border = base01; childBorder = base01; indicator = base01; text = base05; };
          urgent = { background = base08; border = base08; childBorder = base08; indicator = base08; text = base00; };
        };
        keybindings = {
          "${modifier}+Return" = "exec ${terminal}";
          "${modifier}+Shift+q" = "kill";
          "${alt}+F4" = "kill";
          "${modifier}+n" = "exec ${config.home-manager.window-manager.default.browser}";
          "${modifier}+m" = "exec ${config.home-manager.window-manager.default.fileManager}";
          "${modifier}+d" = "exec ${lib.getExe config.programs.fuzzel.package}";
          "${modifier}+f" = "fullscreen toggle";
          "${modifier}+v" = "split v";
          "${modifier}+b" = "split h";
          "${modifier}+s" = "layout stacking";
          "${modifier}+w" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";
          "${modifier}+semicolon" = "focus mode_toggle";
          "${modifier}+Shift+semicolon" = "floating toggle";
          "${modifier}+a" = "focus parent";
          "${modifier}+Shift+minus" = "move scratchpad";
          "${modifier}+minus" = "scratchpad show";
          "${modifier}+r" = ''mode "${resizeMode}"'';
          "${modifier}+Escape" = ''mode "${powerManagementMode}"'';
          "${modifier}+Shift+c" = "reload";
          "${modifier}+Shift+r" = "restart";
          "${modifier}+p" = ''mode "${displayLayoutMode}"'';
          "XF86AudioRaiseVolume" = "exec --no-startup-id ${lib.getExe pkgs.pamixer} --set-limit 150 --allow-boost -i 5";
          "XF86AudioLowerVolume" = "exec --no-startup-id ${lib.getExe pkgs.pamixer} --set-limit 150 --allow-boost -d 5";
          "XF86AudioMute" = "exec --no-startup-id ${lib.getExe pkgs.pamixer} --toggle-mute";
          "XF86AudioMicMute" = "exec --no-startup-id ${lib.getExe pkgs.pamixer} --toggle-mute --default-source";
          "XF86MonBrightnessUp" = "exec --no-startup-id ${lib.getExe pkgs.brightnessctl} --class=backlight set +5%";
          "XF86MonBrightnessDown" = "exec --no-startup-id ${lib.getExe pkgs.brightnessctl} --class=backlight set -5%";
          "XF86AudioPlay" = "exec --no-startup-id ${lib.getExe pkgs.playerctl} play-pause";
          "XF86AudioStop" = "exec --no-startup-id ${lib.getExe pkgs.playerctl} stop";
          "XF86AudioNext" = "exec --no-startup-id ${lib.getExe pkgs.playerctl} next";
          "XF86AudioPrev" = "exec --no-startup-id ${lib.getExe pkgs.playerctl} previous";
          "Print" = "exec --no-startup-id ${fullScreenShot}";
          "Shift+Print" = "exec --no-startup-id ${areaScreenShot}";
          "Ctrl+escape" = "exec ${lib.getExe' pkgs.dunst "dunstctl"} close";
          "Ctrl+Shift+escape" = "exec ${lib.getExe' pkgs.dunst "dunstctl"} close-all";
        }
        // (mapDirectionDefault { prefixKey = modifier; prefixCmd = "focus"; })
        // (mapDirectionDefault { prefixKey = "${modifier}+Shift"; prefixCmd = "move"; })
        // (mapDirectionDefault { prefixKey = "Ctrl+${alt}"; prefixCmd = "move workspace to output"; });
        modes = {
          ${resizeMode} = (mapDirection {
            leftCmd = "resize shrink width 10px or 10ppt";
            downCmd = "resize grow height 10px or 10ppt";
            upCmd = "resize shrink height 10px or 10ppt";
            rightCmd = "resize grow width 10px or 10ppt";
          }) // exitMode;
          ${powerManagementMode} = {
            l = "mode default, exec systemd-run --user loginctl lock-session";
            e = "mode default, exec ${msg} exit";
            s = "mode default, exec systemd-run --user systemctl suspend";
            h = "mode default, exec systemd-run --user systemctl hibernate";
            "Shift+r" = "mode default, exec systemd-run --user systemctl reboot";
            "Shift+s" = "mode default, exec systemd-run --user systemctl poweroff";
          } // exitMode;
          ${displayLayoutMode} = {
            a = "mode default, exec systemctl restart --user kanshi.service";
            g = "mode default, exec ${lib.getExe pkgs.wdisplays}";
          } // exitMode;
        };
        defaultWorkspace = (builtins.head workspaces).name;
        workspaceAutoBackAndForth = true;
        workspaceLayout = "tabbed";
        window = { border = 1; hideEdgeBorders = "smart"; titlebar = false; };
        focus.followMouse = false;
      };
      extraConfig = with config.home.pointerCursor; ''
        ${workspaceBindings { prefixKey = modifier; prefixCmd = "workspace number"; }}
        ${workspaceBindings { prefixKey = "${modifier}+Shift"; prefixCmd = "move container to workspace number"; }}

        seat * xcursor_theme ${name} ${toString size}
      '';
    };
in
{
  options.home-manager.window-manager.wayland.sway.enable = lib.mkEnableOption "Sway config" // {
    default = config.home-manager.window-manager.wayland.enable;
  };

  options.home-manager.window-manager.wayland.sway.nvidia.enable =
    lib.mkEnableOption "NVIDIA Sway support";

  config = lib.mkIf cfg.enable {
    wayland.windowManager.sway = with commonOptions; {
      enable = true;

      inherit extraConfig;

      config = commonOptions.config // {
        input =
          let
            inherit (config.home.keyboard) layout variant options;
          in
          {
            "type:keyboard" = {
              xkb_layout = lib.mkIf (layout != null) layout;
              xkb_variant = lib.mkIf (variant != null) variant;
              xkb_options = lib.mkIf (options != [ ]) (lib.concatStringsSep "," options);
              repeat_delay = "300";
            };
            "type:pointer" = {
              accel_profile = "flat";
            };
            "type:touchpad" = {
              middle_emulation = "enabled";
              natural_scroll = "enabled";
              scroll_method = "two_finger";
              tap = "enabled";
            };
          };

        output = {
          "*" = with config.theme.wallpaper; {
            bg = "${path} ${scale}";
            # DPI
            scale = toString (config.theme.fonts.dpi / 100.0);
            subpixel = config.fonts.fontconfig.subpixelRendering;
          };
        };
      };

      extraSessionCommands =
        # bash
        ''
          # Source home-manager session vars
          . "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh"
          # Vulkan renderer
          export WLR_RENDERER=vulkan,gles2,pixman
          # Chrome/Chromium/Electron
          export NIXOS_OZONE_WL=1
          # SDL
          export SDL_VIDEODRIVER=wayland
          # Fix for some Java AWT applications (e.g. Android Studio),
          # use this if they aren't displayed properly:
          export _JAVA_AWT_WM_NONREPARENTING=1
        '';

      systemd = {
        enable = true;
        xdgAutostart = true;
      };

      wrapperFeatures.gtk = true;

      extraOptions = lib.optionals cfg.nvidia.enable [
        "--unsupported-gpu"
      ];
    };
  };
}

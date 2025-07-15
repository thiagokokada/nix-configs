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

    text =
      let
        # TODO: make this derived from the configuration
        terminal = "kitty";
      in
      # bash
      ''
        set +o errexit
        pid="$(swaymsg -t get_tree | jq -e '.. | select(.type? and .focused? and .app_id=="${terminal}") | .pid')"
        if [[ -n "$pid" ]]; then
          ppid="$(pgrep --newest --parent "$pid")"
          exec ${terminal} "$(readlink "/proc/$ppid/cwd" || echo "$HOME")"
        fi
        exec ${terminal}
      '';
  };

  commonOptions =
    let
      screenShotName =
        with config.xdg.userDirs;
        "${pictures}/$(${lib.getExe' pkgs.coreutils "date"} +%Y-%m-%d_%H-%M-%S)-screenshot.png";
      displayLayoutMode = " : [a]uto, [g]ui";
    in
    import ../x11/i3/common.nix rec {
      inherit
        config
        lib
        pkgs
        modifier
        alt
        ;
      bars = [ ];
      menu = lib.getExe config.programs.fuzzel.package;

      msg = lib.getExe' pkgs.sway "swaymsg";

      fullScreenShot = ''
        ${lib.getExe pkgs.grim} "${screenShotName}" && \
        ${lib.getExe pkgs.libnotify} -u normal -t 5000 'Full screenshot taken'
      '';
      areaScreenShot = ''
        ${lib.getExe pkgs.grim} -g "$(${lib.getExe pkgs.slurp})" "${screenShotName}" && \
        ${lib.getExe pkgs.libnotify} -u normal -t 5000 'Area screenshot taken'
      '';

      extraBindings = {
        "${modifier}+p" = ''mode "${displayLayoutMode}"'';
      };

      extraModes = {
        ${displayLayoutMode} = {
          a = "mode default, exec systemctl restart --user kanshi.service";
          g = "mode default, exec ${lib.getExe pkgs.wdisplays}";
          "Escape" = "mode default";
          "Return" = "mode default";
        };
      };

      extraConfig = with config.xsession.pointerCursor; ''
        hide_edge_borders --i3 smart

        # XCURSOR_SIZE
        seat * xcursor_theme ${name} ${toString size}
      '';

      terminal = lib.getExe terminal-cwd;
    };
in
{
  options.home-manager.window-manager.wayland.sway.enable = lib.mkEnableOption "Sway config" // {
    default = config.home-manager.window-manager.wayland.enable;
  };

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
            subpixel = config.home-manager.window-manager.fonts.fontconfig.subpixel.rgba;
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

      extraOptions = lib.optionals config.home-manager.window-manager.x11.nvidia.enable [
        "--unsupported-gpu"
      ];
    };

    xsession.preferStatusNotifierItems = true;

    home.packages = with pkgs; [
      wdisplays
      wl-clipboard
    ];
  };
}

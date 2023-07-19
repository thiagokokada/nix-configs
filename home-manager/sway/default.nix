{ config, lib, pkgs, osConfig, ... }:
let
  # Aliases
  alt = "Mod1";
  modifier = "Mod4";

  commonOptions =
    let
      dunstctl = "${pkgs.dunst}/bin/dunstctl";
      screenShotName = with config.xdg.userDirs;
        "${pictures}/$(${pkgs.coreutils}/bin/date +%Y-%m-%d_%H-%M-%S)-screenshot.png";
      displayLayoutMode = " : [a]uto, [g]ui";
    in
    import ../i3/common.nix rec {
      inherit config lib modifier alt dunstctl;
      browser = "firefox";
      bars = [{ command = "${config.programs.waybar.package}/bin/waybar"; }];
      fileManager = "${terminal} ${config.programs.nnn.finalPackage}/bin/nnn -a -P p";
      menu = "${config.programs.fuzzel.package}/bin/fuzzel";
      # light needs to be installed in system, so not defining a path here
      light = "light";
      pamixer = "${pkgs.pamixer}/bin/pamixer";
      playerctl = "${pkgs.playerctl}/bin/playerctl";
      terminal = "${config.programs.kitty.package}/bin/kitty";

      fullScreenShot = ''
        ${pkgs.grim}/bin/grim "${screenShotName}" && \
        ${pkgs.libnotify}/bin/notify-send -u normal -t 5000 'Full screenshot taken'
      '';
      areaScreenShot = ''
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" "${screenShotName}" && \
        ${pkgs.libnotify}/bin/notify-send -u normal -t 5000 'Area screenshot taken'
      '';

      extraBindings = {
        "${modifier}+p" = ''mode "${displayLayoutMode}"'';
      };

      extraModes = {
        ${displayLayoutMode} = {
          a = "mode default, exec systemctl restart --user kanshi.service";
          g = "mode default, exec ${pkgs.wdisplays}/bin/wdisplays";
          "Escape" = "mode default";
          "Return" = "mode default";
        };
      };

      extraConfig = with config.xsession.pointerCursor; ''
        hide_edge_borders --i3 smart

        # XCURSOR_SIZE
        seat * xcursor_theme ${name} ${toString size}
      '';
    };
in
{
  imports = [
    ../i3/gammastep.nix
    ../i3/dunst.nix
    ./kanshi
    ./fuzzel.nix
    ./swayidle.nix
    ./swaylock.nix
    ./waybar.nix
  ];

  home.packages = with pkgs; [
    wdisplays
    wl-clipboard
  ];

  wayland.windowManager.sway = with commonOptions; {
    enable = true;

    inherit extraConfig;

    config = commonOptions.config // {
      startup = [
        { command = "systemctl restart --user kanshi.service"; always = true; }
      ];

      input = {
        "type:keyboard" = {
          xkb_layout = "us(intl)";
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
          bg = "${config.theme.wallpaper.path} ${config.theme.wallpaper.scale}";
          # DPI
          scale = (toString (125 / 100.0));
        } // lib.optionalAttrs (osConfig ? fonts.fontconfig) {
          subpixel = osConfig.fonts.fontconfig.subpixel.rgba;
        };
      };
    };

    extraSessionCommands = ''
      # Source home-manager session vars
      . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
      # Firefox
      export MOZ_ENABLE_WAYLAND=1
      # Chrome/Chromium/Electron
      export NIXOS_OZONE_WL=1
      # Qt
      export QT_QPA_PLATFORM=wayland
      export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
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

    wrapperFeatures = {
      base = true;
      gtk = true;
    };

    extraOptions = lib.optionals (pkgs.lib.isNvidia osConfig) [
      "--unsupported-gpu"
    ];
  };

  xsession.preferStatusNotifierItems = true;

  systemd.user.services.wl-clip-persist = {
    Unit = {
      Description = "Keep Wayland clipboard even after programs close";
      PartOf = [ "graphical-session.target" ];
    };

    Install = { WantedBy = [ "sway-session.target" ]; };

    Service = {
      ExecStart = "${pkgs.wl-clip-persist}/bin/wl-clip-persist --clipboard both";
      Restart = "on-failure";
    };
  };
}

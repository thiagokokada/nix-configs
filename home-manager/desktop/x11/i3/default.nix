{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Aliases
  alt = "Mod1";
  modifier = "Mod4";

  commonOptions =
    let
      rofi = lib.getExe config.programs.rofi.package;
      mons = lib.getExe pkgs.mons;
      screenShotName =
        with config.xdg.userDirs;
        "${pictures}/$(${lib.getExe' pkgs.coreutils "date"} +%Y-%m-%d_%H-%M-%S)-screenshot.png";
      displayLayoutMode = " : [h]  , [j]  , [k]  , [l]  , [a]uto, [d]uplicate, [m]irror, [s]econd-only, primary-[o]nly";
    in
    import ./common.nix rec {
      inherit
        config
        lib
        pkgs
        modifier
        alt
        ;

      statusCommand =
        with config;
        "${lib.getExe programs.i3status-rust.package} ${xdg.configHome}/i3status-rust/config-i3.toml";
      menu = "${rofi} -show drun";

      # Screenshots
      fullScreenShot = ''
        ${lib.getExe pkgs.maim} -u "${screenShotName}" && \
        ${lib.getExe pkgs.libnotify} -u normal -t 5000 'Full screenshot taken'
      '';
      areaScreenShot = ''
        ${lib.getExe pkgs.maim} -u -s "${screenShotName}" && \
        ${lib.getExe pkgs.libnotify} -u normal -t 5000 'Area screenshot taken'
      '';

      extraBindings = {
        "${modifier}+p" = ''mode "${displayLayoutMode}"'';
        "${modifier}+c" = "exec ${rofi} -show calc -modi calc -no-show-match -no-sort";
        "${modifier}+Tab" = "exec ${rofi} -show window -modi window";
      };

      extraModes =
        with commonOptions.helpers;
        let
          runMons =
            action: "mode default, exec ${mons} ${action} && systemctl --user restart wallpaper.service";
        in
        {
          ${displayLayoutMode} =
            (mapDirection {
              leftCmd = runMons "-e left";
              downCmd = runMons "-e bottom";
              upCmd = runMons "-e top";
              rightCmd = runMons "-e right";
            })
            // {
              a = lib.mkIf config.home-manager.desktop.x11.autorandr.enable "mode default, exec ${lib.getExe pkgs.autorandr} --change --default default";
              d = runMons "-d";
              m = runMons "-m";
              s = runMons "-s";
              o = runMons "-o";
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
  options.home-manager.desktop.x11.i3.enable = lib.mkEnableOption "i3 config" // {
    default = config.home-manager.desktop.x11.enable;
  };

  config = lib.mkIf config.home-manager.desktop.x11.i3.enable {
    home = {
      packages = with pkgs; [
        arandr
        dex
        feh
        maim
        mons
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
            command = "${lib.getExe pkgs.dex} --autostart";
            notification = false;
          }
        ];

      };
    };
  };
}

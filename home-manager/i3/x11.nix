{ super, config, lib, pkgs, ... }:
let
  xsession = "${config.home.homeDirectory}/.xsession";
in
{
  # Compatibility with xinit/sx
  home.file.".xinitrc".source = config.lib.file.mkOutOfStoreSymlink xsession;
  xdg.configFile."sx/sxrc".source = config.lib.file.mkOutOfStoreSymlink xsession;

  systemd.user.services =
    let
      multipleKbLayouts = with builtins;
        (length
          (split "," (super.services.xserver.layout or ""))) > 1;
    in
    {
      xss-lock = {
        Unit = {
          Description = "Use external locker as X screen saver";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Install = { WantedBy = [ "graphical-session.target" ]; };

        Service =
          let
            lockscreen = with config.theme.fonts;
              pkgs.writeShellScriptBin "lock-screen" ''
                export XSECURELOCK_FORCE_GRAB=1
                export XSECURELOCK_BLANK_DPMS_STATE="off"
                export XSECURELOCK_DATETIME_FORMAT="%H:%M:%S - %a %d/%m"
                export XSECURELOCK_SHOW_DATETIME=1
                export XSECURELOCK_SHOW_HOSTNAME=0
                export XSECURELOCK_SHOW_USERNAME=0
                # workaround issue with picom
                export XSECURELOCK_COMPOSITE_OBSCURER=0
                export XSECURELOCK_DISCARD_FIRST_KEYPRESS=0
                export XSECURELOCK_FONT="${gui.name}:style=Regular"

                exec ${pkgs.xsecurelock}/bin/xsecurelock $@
              '';
            notify = pkgs.writeShellScriptBin "notify" ''
              ${pkgs.libnotify}/bin/notify-send -t 30 "30 seconds to lock"
            '';
          in
          {
            ExecStart = lib.concatStringsSep " " [
              "${pkgs.xss-lock}/bin/xss-lock"
              "--notifier ${notify}/bin/notify"
              "--transfer-sleep-lock"
              "--session $XDG_SESSION_ID"
              "--"
              "${lockscreen}/bin/lock-screen"
            ];
          };
      };

      wallpaper = {
        Unit = {
          Description = "Set wallpaper";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Install = { WantedBy = [ "graphical-session.target" ]; };

        Service = {
          ExecStart = lib.concatStringsSep " " [
            "${pkgs.feh}/bin/feh"
            "--no-fehbg"
            "--bg-${config.theme.wallpaper.scale}"
            "${config.theme.wallpaper.path}"
          ];
          Type = "oneshot";
        };
      };
    } // (lib.optionalAttrs multipleKbLayouts {
      kbdd = {
        Unit = {
          Description = "kbdd daemon";
          Requires = [ "dbus.service" ];
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Install = { WantedBy = [ "graphical-session.target" ]; };

        Service = {
          ExecStart = "${pkgs.kbdd}/bin/kbdd -n";
          Type = "dbus";
          BusName = "ru.gentoo.KbddService";
        };
      };
    });

  xresources.properties = with config.theme.fonts; {
    "Xft.dpi" = (toString dpi);
  };

  xsession = {
    enable = true;
    initExtra =
      # NVIDIA sync
      lib.optionalString (super.hardware.nvidia.prime.sync.enable or false) ''
        ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource modesetting NVIDIA-0
        ${pkgs.xorg.xrandr}/bin/xrandr --auto
      ''
      # Reverse PRIME
      + lib.optionalString (super.hardware.nvidia.prime.offload.enable or false) ''
        ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource NVIDIA-G0 modesetting
      ''
      # Automatically loads the best layout from autorandr
      + ''
        ${pkgs.autorandr}/bin/autorandr --change
      '';
  };
}

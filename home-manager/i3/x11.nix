{ config, lib, pkgs, osConfig, ... }:
let
  xsession = "${config.home.homeDirectory}/.xsession";
in
{
  # Compatibility with xinit/sx
  home.file.".xinitrc".source = config.lib.file.mkOutOfStoreSymlink xsession;
  xdg.configFile."sx/sxrc".source = config.lib.file.mkOutOfStoreSymlink xsession;

  systemd.user.services = {
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
              export XSECURELOCK_FONT="${gui.name}:style=Regular"

              exec ${pkgs.xsecurelock}/bin/xsecurelock $@
            '';
          notify = pkgs.writeShellScript "notify" ''
            ${pkgs.dunst}/bin/dunstify -t 30000 "30 seconds to lock"
          '';
        in
        {
          ExecStart = lib.concatStringsSep " " [
            "${pkgs.xss-lock}/bin/xss-lock"
            "--notifier ${notify}"
            "--transfer-sleep-lock"
            "--session $XDG_SESSION_ID"
            "--"
            "${lockscreen}/bin/lock-screen"
          ];
          Restart = "on-failure";
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
  };

  xresources.properties = with config.theme.fonts; {
    "Xft.dpi" = (toString dpi);
  };

  xsession = {
    enable = true;
    initExtra =
      # NVIDIA sync
      lib.optionalString (osConfig.hardware.nvidia.prime.sync.enable or false) ''
        ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource modesetting NVIDIA-0
        ${pkgs.xorg.xrandr}/bin/xrandr --auto
      ''
      # Reverse PRIME
      + lib.optionalString (osConfig.hardware.nvidia.prime.offload.enable or false) ''
        ${pkgs.xorg.xrandr}/bin/xrandr --setprovideroutputsource NVIDIA-G0 modesetting
      ''
      # Automatically loads the resolution
      + ''
        ${pkgs.change-res}/bin/change-res
      '';
  };
}

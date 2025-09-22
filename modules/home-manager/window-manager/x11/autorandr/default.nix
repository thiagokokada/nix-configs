{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.home-manager.window-manager.x11.autorandr;
in
{
  options.home-manager.window-manager.x11.autorandr = {
    enable = lib.mkEnableOption "autorandr config" // {
      default = config.home-manager.window-manager.x11.enable;
    };
    defaultProfile = lib.mkOption {
      description = "Default autorandr profile.";
      type = lib.types.str;
      default = "horizontal";
    };
    extraHooks = lib.mkOption {
      description = "Additional hooks.";
      type = lib.types.attrs;
      default =
        let
          inherit (config.home-manager) hostName;
          configFile = ./${hostName}.nix;
        in
        lib.optionalAttrs (builtins.pathExists configFile) (import configFile);
    };
  };

  config = lib.mkIf cfg.enable {
    home.activation =
      let
        inherit (config.xdg) configHome;
      in
      {
        autorandrCreateDefaultProfile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run mkdir -p "${configHome}/autorandr"
          run cd "${configHome}/autorandr"
          run ln -sf $VERBOSE_ARG ${cfg.defaultProfile} default
        '';
      };

    programs.autorandr = {
      enable = true;
      hooks = lib.mkMerge [
        {
          postswitch = {
            notify-i3 = "${lib.getExe' pkgs.i3 "i3-msg"} restart";
            reset-wallpaper = "systemctl restart --user wallpaper.service";
          };
        }
        cfg.extraHooks
      ];
    };

    xsession.initExtra = lib.mkAfter ''
      ${lib.getExe pkgs.autorandr} --change --default default
    '';

    # Configure autorandr globally
    xdg.configFile = {
      # Skip gamma settings since this is controlled by gammastep
      "autorandr/settings.ini" = {
        inherit (config.programs.autorandr) enable;
        text = lib.generators.toINI { } {
          config = {
            skip-options = "gamma";
          };
        };
      };
    };
  };
}

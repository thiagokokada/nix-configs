{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  hostName = osConfig.networking.hostName or "generic";
  hostConfigFile = ./${hostName}.nix;
  cfg = config.home-manager.window-manager.x11.autorandr;
in
{
  imports = lib.optionals (builtins.pathExists hostConfigFile) [ hostConfigFile ];

  options.home-manager.window-manager.x11.autorandr = {
    enable = lib.mkEnableOption "autorandr config" // {
      default = config.home-manager.window-manager.x11.enable;
    };
    defaultProfile = lib.mkOption {
      description = "Default autorandr profile.";
      type = lib.types.str;
      default = "horizontal";
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
      hooks = {
        postswitch = {
          notify-i3 = "${lib.getExe' pkgs.i3 "i3-msg"} restart";
          reset-wallpaper = "systemctl restart --user wallpaper.service";
        };
      };
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

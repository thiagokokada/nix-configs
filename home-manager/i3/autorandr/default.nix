{ config, lib, pkgs, osConfig, ... }:

let
  hostName = osConfig.networking.hostName or "generic";
  hostConfigFile = ./${hostName}.nix;
in
{
  imports = lib.optionals (builtins.pathExists hostConfigFile) [ hostConfigFile ];

  home.activation = let inherit (config.xdg) configHome; in {
    # Set default profile to the virtual horizontal profile
    autorandrCreateDefaultProfile = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      cd "${configHome}/autorandr"
      $DRY_RUN_CMD ln -sf $VERBOSE_ARG horizontal default
    '';
  };

  programs.autorandr = {
    enable = true;
    hooks = {
      postswitch = {
        notify-i3 = "${pkgs.i3}/bin/i3-msg restart";
        reset-wallpaper = "systemctl restart --user wallpaper.service";
      };
    };
  };

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
}

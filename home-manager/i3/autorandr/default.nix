{ super, config, lib, pkgs, ... }:

let
  hostName = super.networking.hostName or "";
  hostConfigFile = ./${hostName}.nix;
in
{
  imports = lib.optionals (builtins.pathExists hostConfigFile) [ hostConfigFile ];

  # Set default profile to the virtual horizontal profile
  home.activation.autorandrCreateDefaultProfile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cd "$HOME/.config/autorandr"
    if [[ ! -L default ]]; then
      $DRY_RUN_CMD ln -s $VERBOSE_ARG horizontal default
    fi
  '';

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

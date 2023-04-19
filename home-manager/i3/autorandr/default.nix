{ super, lib, pkgs, ... }:

let
  hostName = super.networking.hostName or "";
  hostConfigFile = ./${hostName}.nix;
in
{
  imports = lib.optionals (builtins.pathExists hostConfigFile) [ hostConfigFile ];

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
    # Set default profile as horizontal
    "autorandr/default" = pkgs.writeTextDir "horizontal" "";
    # Skip gamma settings since this is controlled by gammastep
    "autorandr/settings.ini" = {
      inherit (config.programs.autorandr) enable;
      text = lib.generators.toINI { } {
        config.skip-options = "gamma";
      };
    };
  };
}

{ super, lib, pkgs, ... }:

let
  hostName = super.networking.hostName or "no-existing-hostname";
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
}

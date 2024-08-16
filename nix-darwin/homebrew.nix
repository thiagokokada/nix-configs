{ config, lib, ... }:

let
  cfg = config.nix-darwin.homebrew;
in
{
  options.nix-darwin.homebrew.enable = lib.mkEnableOption "Homebrew config";

  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;
      casks = [
        "betterdisplay"
        "domzilla-caffeine"
        "firefox"
        "google-chrome"
        "linearmouse"
        "rectangle"
      ];
    };
  };
}

{ config, lib, ... }:

let
  cfg = config.nix-darwin.homebrew;
in
{
  options.nix-darwin.homebrew.enable = lib.mkEnableOption "Homebrew config" // {
    default = true;
  };

  config = lib.mkIf cfg.enable {
    homebrew = {
      enable = true;
      casks = [
        "betterdisplay"
        "firefox"
        "google-chrome"
        "linearmouse"
        "rectangle"
      ];
    };
  };
}

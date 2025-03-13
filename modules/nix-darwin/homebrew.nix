{ config, lib, ... }:

let
  cfg = config.nix-darwin.homebrew;
  inherit (config.meta) username;
in
{
  options.nix-darwin.homebrew = {
    enable = lib.mkEnableOption "Homebrew config" // {
      default = true;
    };
  };

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

    home-manager.users.${username}.home-manager.darwin.homebrew = {
      enable = true;
      prefix = lib.removeSuffix "/bin" config.homebrew.brewPrefix;
    };
  };
}

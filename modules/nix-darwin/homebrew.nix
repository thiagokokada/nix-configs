{ config, lib, ... }:

let
  cfg = config.nix-darwin.homebrew;
  inherit (config.nix-darwin.home) username;
in
{
  options.nix-darwin.homebrew = {
    enable = lib.mkEnableOption "Homebrew config" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    nix-darwin.home.extraModules = {
      home-manager.editor.idea.packages = null;
      programs = {
        firefox.package = null;
        kitty.package = null;
      };
    };

    homebrew = {
      enable = true;
      user = config.nix-darwin.home.username;
      casks = [
        "betterdisplay"
        "domzilla-caffeine"
        "firefox"
        "google-chrome"
        "intellij-idea-ce"
        "kitty"
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

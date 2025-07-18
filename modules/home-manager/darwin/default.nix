{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.home-manager.darwin;
in
{
  imports = [
    ./copy-apps.nix
    ./homebrew.nix
  ];

  options.home-manager.darwin = {
    enable = lib.mkEnableOption "Darwin (macOS) config" // {
      default = pkgs.stdenv.isDarwin;
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager = {
      dev.enable = true;
      desktop = {
        # mpv.enable = true;
        kitty = {
          enable = true;
          fontSize = 14.0;
          opacity = 1.0;
        };
      };
    };

    targets.darwin.defaults = {
      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
        AppleShowAllExtensions = true;
        KeyRepeat = 2;
        # Disable all automatic substitution
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
      # Do not write .DS_Store files outside macOS
      com.apple.desktopservices = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };
      # Disable mouse acceleration
      com.apple.mouse.scalling = -1;
      # com.apple.trackpad.scalling = -1;
    };
  };
}

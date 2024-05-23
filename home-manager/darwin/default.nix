{ config, lib, pkgs, ... }:

let
  cfg = config.home-manager.darwin;
in
{
  imports = [
    ./remap-keys.nix
    ./trampoline-apps.nix
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
        wezterm = {
          enable = pkgs.stdenv.isAarch64; # broken in x86_64-darwin
          fullscreenOnStartup = false;
          fontSize = 14.0;
          opacity = 1.0;
        };
      };
    };

    targets.darwin.defaults = {
      NSGlobalDomain = {
        ApplePressAndHoldEnabled = true;
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

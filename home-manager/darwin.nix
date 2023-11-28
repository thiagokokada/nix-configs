{ config, lib, pkgs, ... }:

{
  options.home-manager.darwin.enable = lib.mkEnableOption "Darwin config" // {
    default = pkgs.stdenv.isDarwin;
  };

  config = lib.mkIf config.home-manager.darwin.enable {
    home-manager = {
      dev = {
        enable = true;
        clojure.enable = false;
      };
      editor.emacs.enable = true;
    };

    targets.darwin.defaults = {
      # Disable all automatic substitution
      NSGlobalDomain = {
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

{ config, lib, pkgs, ... }:

{
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
  };
}

{ ... }:

{
  imports = [
    ./emacs
    ./helix.nix
    ./minimal.nix
    ./mpv
    ./nnn.nix
    ./non-nix.nix
  ];

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
}

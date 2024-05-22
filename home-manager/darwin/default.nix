{ config, lib, pkgs, ... }:

let
  cfg = config.home-manager.darwin;
in
{
  imports = [ ./trampoline-apps.nix ];

  options.home-manager.darwin = {
    enable = lib.mkEnableOption "Darwin (macOS) config" // {
      default = pkgs.stdenv.isDarwin;
    };
    # https://developer.apple.com/library/archive/technotes/tn2450/_index.html
    remapKeys.enable = lib.mkEnableOption "remap '§±' with '`~' (for UK keyboards, requires root)" // {
      default = cfg.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    home.activation.remapKeys = lib.mkIf cfg.remapKeys.enable
      (lib.hm.dag.entryAfter [ "writeBoundary" ] /* bash */ ''
        destination="/Library/LaunchDaemons/com.nix.remakeys.plist"
        if ! ${lib.getExe' pkgs.diffutils "diff"} "${./remapkeys.plist}" "$destination"; then
          $DRY_RUN_CMD /usr/bin/sudo ${lib.getExe' pkgs.coreutils "cp"} "${./remapkeys.plist}" "$destination"
          $DRY_RUN_CMD /usr/bin/sudo /bin/launchctl load -w "$destination"
        fi
      '');

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

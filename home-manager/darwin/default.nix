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
    # https://gist.github.com/paultheman/808be117d447c490a29d6405975d41bd
    remapKeys.enable = lib.mkEnableOption "remap internal Macbook keyboard keys from '§±' to '`~' (EU -> US, requires root)";
  };

  config = lib.mkIf cfg.enable {
    home.activation.remapKeys = lib.mkIf cfg.remapKeys.enable
      (lib.hm.dag.entryAfter [ "writeBoundary" ] /* bash */ ''
        source="${./remapkeys.plist}"
        destination="/Library/LaunchDaemons/com.nix.remakeys.plist"
        if ! ${lib.getExe' pkgs.diffutils "diff"} "$source" "$destination"; then
          $DRY_RUN_CMD /usr/bin/sudo ${lib.getExe' pkgs.coreutils "install"} -m 644 "$source" "$destination"
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

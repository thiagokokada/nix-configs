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
  imports = [ ./remap-keys.nix ];

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
        wezterm = {
          enable = true;
          fullscreenOnStartup = false;
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

    home.activation.link-apps =
      lib.hm.dag.entryAfter [ "linkGeneration" ]
        # bash
        ''
          new_nix_apps="${config.home.homeDirectory}/Applications/Nix"
          rm -rf "$new_nix_apps"
          mkdir -p "$new_nix_apps"
          find -H -L "$genProfilePath/home-files/Applications" -name "*.app" -type d -print | while read -r app; do
            real_app=$(readlink -f "$app")
            app_name=$(basename "$app")
            target_app="$new_nix_apps/$app_name"
            echo "Alias '$real_app' to '$target_app'"
            ${pkgs.mkalias}/bin/mkalias "$real_app" "$target_app"
          done
        '';
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (config.home) username;
  cfg = config.home-manager.desktop.firefox;
  cfgFc = config.home-manager.desktop.fonts.fontconfig;
in
{
  options.home-manager.desktop.firefox = {
    enable = lib.mkEnableOption "Firefox config" // {
      default = config.home-manager.desktop.enable;
    };
    subpixelRender.enable = lib.mkEnableOption "subpixel render" // {
      default = cfgFc.antialias && (cfgFc.subpixel.rgba != "none");
    };
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles.${username} = {
        settings = {
          # disable about:config warning
          "browser.aboutConfig.showWarning" = false;
          # disable annoying Ctrl+Q shortcut
          "browser.quitShortcut.disabled" = true;
          # don't mess up with paste
          "dom.event.clipboardevents.enabled" = false;
          # handpicked settings from: https://github.com/arkenfox/user.js/blob/master/user.js
          # ads
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
          "browser.newtabpage.activity-stream.showSponsoredCheckboxes" = false;
          "browser.urlbar.suggest.quicksuggest.sponsored" = false;
          # clear default topsites, does not block you from adding your own
          "browser.newtabpage.activity-stream.default.sites" = "";
          "extensions.htmlaboutaddons.recommendations.enabled" = false;
          # data reporting
          "datareporting.policy.dataSubmissionEnable" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          # telemetry
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.updatePing.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.coverage.opt-out" = true;
          "toolkit.coverage.opt-out" = true;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          # studies
          "app.shield.optoutstudies.enabled" = false;
          "app.normandy.enabled" = false;
          # crash report
          "browser.tabs.crashReporting.sendReport" = false;
          # breaks a few things, like auto dark-mode in websites
          # "privacy.resistFingerprinting" = true;
        }
        // lib.optionalAttrs cfg.subpixelRender.enable {
          # https://pandasauce.org/get-fonts-done/
          "gfx.text.subpixel-position.force-enabled" = true;
          "gfx.webrender.quality.force-subpixel-aa-where-possible" = true;
        };
      };
    };
  };
}

{ config, lib, ... }:

{
  options.nixos.desktop.chromium.enable = lib.mkEnableOption "Chromium config" // {
    default = config.nixos.desktop.enable;
  };

  config = lib.mkIf config.nixos.desktop.chromium.enable {
    nixos.home.extraModules = {
      # This module is policy only, we need to enable the package itself
      home-manager.desktop.chromium.enable = true;
    };

    programs.chromium = {
      enable = true;
      enablePlasmaBrowserIntegration = lib.mkDefault config.nixos.desktop.kde.enable;
      defaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
      extensions = [
        "cjpalhdlnbpafiamejdnhcphjbkeiagm" # ublock origin
        "hfjbmagddngcpeloejdejnfgbamkjaeg" # vimium-c
      ];
      initialPrefs = {
        "sync_promo" = {
          "show_on_first_run_allowed" = false;
        };
      };
    };
  };
}

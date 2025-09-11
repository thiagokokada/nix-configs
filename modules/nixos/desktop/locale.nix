{ config, lib, ... }:

{
  options.nixos.desktop.locale.enable = lib.mkEnableOption "locale config" // {
    default = config.nixos.desktop.enable;
  };

  config = lib.mkIf config.nixos.desktop.locale.enable {
    # Select internationalisation properties.
    i18n = {
      defaultLocale = lib.mkDefault "en_IE.UTF-8";
      extraLocaleSettings = {
        LC_CTYPE = lib.mkDefault "pt_BR.UTF-8"; # Fix ç in us-intl.
      };
      inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5.waylandFrontend = true;
      };
    };

    # Set your time zone.
    time.timeZone = lib.mkDefault "America/Sao_Paulo";
  };
}

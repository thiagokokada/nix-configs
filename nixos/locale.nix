{ config, lib, pkgs, ... }:

{
  # Select internationalisation properties.
  i18n = {
    inputMethod.enabled = "uim";
    defaultLocale = lib.mkDefault "en_IE.UTF-8";
    extraLocaleSettings = {
      LC_CTYPE = lib.mkDefault "pt_BR.UTF-8"; # Fix ç in us-intl.
      LC_TIME = lib.mkDefault "pt_BR.UTF-8";
    };
  };

  # Set X11 keyboard layout.
  services.xserver = {
    layout = lib.mkDefault "us";
    xkbVariant = lib.mkDefault "intl";
    xkbOptions = lib.mkDefault "grp:win_space_toggle";
  };

  # Set your time zone.
  time.timeZone = lib.mkDefault "America/Sao_Paulo";
}

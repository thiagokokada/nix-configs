{ config, lib, pkgs, ... }:

{
  # Change some default locales
  environment.variables = {
    LC_CTYPE = "pt_BR.UTF-8"; # Fix ç in us-intl.
    LC_TIME = "pt_BR.UTF-8";
    LC_COLLATE = "C"; # Use C style string sort.
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Set X11 keyboard layout.
  services.xserver = {
    layout = "us,br";
    xkbVariant = "intl,abnt2";
  };

  # Set your time zone.
  time.timeZone = "America/Sao_Paulo";
}

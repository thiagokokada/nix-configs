{ config, lib, pkgs, ... }:

{
  # Select internationalisation properties.
  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    extraLocaleSettings = {
      LC_CTYPE = lib.mkDefault "pt_BR.UTF-8"; # Fix ç in us-intl.
      LC_TIME = lib.mkDefault "pt_BR.UTF-8";
      LC_COLLATE = lib.mkDefault "C"; # Use C style string sort.
    };
  };

  # Set X11 keyboard layout.
  services.xserver = {
    layout = lib.mkDefault "us";
    xkbVariant = lib.mkDefault "intl";
    # Remap Caps Lock to Esc, and use Super+Space to change layouts
    xkbOptions = lib.mkDefault "caps:escape,grp:win_space_toggle";
  };

  # Set your time zone.
  time.timeZone = lib.mkDefault "America/Sao_Paulo";
}

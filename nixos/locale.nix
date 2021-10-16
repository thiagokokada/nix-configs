{ config, lib, pkgs, ... }:

{
  # Select internationalisation properties.
  i18n = lib.mkDefault {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_CTYPE = "pt_BR.UTF-8"; # Fix ç in us-intl.
      LC_TIME = "pt_BR.UTF-8";
      LC_COLLATE = "C"; # Use C style string sort.
    };
  };

  # Set X11 keyboard layout.
  services.xserver = lib.mkDefault {
    layout = "us,br";
    xkbVariant = "intl,abnt2";
    # Remap Caps Lock to Esc, and use Super+Space to change layouts
    xkbOptions = "caps:escape,grp:win_space_toggle";
  };

  # Set your time zone.
  time.timeZone = lib.mkDefault "America/Sao_Paulo";
}

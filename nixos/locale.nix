{ config, lib, pkgs, ... }:

{
  # https://www.reddit.com/r/firefox/comments/wq5whz/cant_type_accented_characters_on_some_websites/iq92ve6/
  environment.variables = {
    GTK_IM_MODULE = "xim";
    QT_IM_MODULE = "xim";
  };

  # Select internationalisation properties.
  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    extraLocaleSettings = {
      LC_CTYPE = lib.mkDefault "pt_BR.UTF-8"; # Fix ç in us-intl.
      LC_TIME = lib.mkDefault "pt_BR.UTF-8";
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

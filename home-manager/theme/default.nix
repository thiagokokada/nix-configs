{ super, config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/theme.nix
  ];

  theme = {
    fonts = {
      gui = {
        package = pkgs.roboto;
        name = "Roboto";
      };
      icons = {
        package = pkgs.font-awesome_6;
        name = [
          "Font Awesome 6 Brands"
          "Font Awesome 6 Free Solid"
        ];
      };
    };
    colors = with builtins; fromJSON (readFile ./colors.json);
    wallpaper.path = lib.mkDefault pkgs.wallpapers.hatsune-miku_walking-4k;
  };

  # Enable fonts in home.packages to be available to applications
  fonts.fontconfig.enable = true;

  home = {
    packages = with pkgs; [
      config.theme.fonts.gui.package
      config.theme.fonts.icons.package
      dejavu_fonts
      gnome.gnome-themes-extra
      hack-font
      hicolor-icon-theme
      liberation_ttf
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];

    pointerCursor = {
      package = pkgs.nordzy-cursor-theme;
      name = "Nordzy-cursors";
      size = 24;
      x11.enable = true;
      gtk.enable = true;
    };
  };

  gtk = {
    enable = true;
    font = {
      package = pkgs.noto-fonts;
      name = "Noto Sans";
    };
    iconTheme = {
      package = pkgs.nordzy-icon-theme;
      name = "Nordzy-dark";
    };
    theme = {
      name = "Nordic-bluish-accent";
      package = pkgs.nordic;
    };
  };

  qt = {
    enable = true;
    platformTheme = "qtct";
    style.name = "kvantum";
  };

  xdg.configFile = {
    "Kvantum/kvantum.kvconfig".text = lib.generators.toINI { } {
      General.theme = "Nordic-bluish-solid";
    };
    "Kvantum" = {
      source = "${pkgs.nordic}/share/Kvantum";
      recursive = true;
    };
    "qt5ct/qt5ct.conf".text = lib.generators.toINI { } {
      Appearance = {
        style = "kvantum-dark";
        icon_theme = config.gtk.iconTheme.name;
      };
      Interface = {
        activate_item_on_single_click = 0;
      };
      Fonts = {
        # Noto Sans Mono 10
        fixed = ''@Variant(\0\0\0@\0\0\0\x1c\0N\0o\0t\0o\0 \0S\0\x61\0n\0s\0 \0M\0o\0n\0o@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)'';
        # Noto Sans 10
        general = ''@Variant(\0\0\0@\0\0\0\x12\0N\0o\0t\0o\0 \0S\0\x61\0n\0s@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)'';
      };
    };
    "qt6ct/qt6ct.conf".text = config.xdg.configFile."qt5ct/qt5ct.conf".text;
  };

  # https://github.com/GNOME/gsettings-desktop-schemas/blob/8527b47348ce0573694e0e254785e7c0f2150e16/schemas/org.gnome.desktop.interface.gschema.xml.in#L276-L296
  dconf.settings = lib.optionalAttrs (super ? fonts.fontconfig) {
    # hide ibus systray icon, kinda buggy in waybar
    "desktop/ibus/panel".show-icon-on-systray = false;
    "org/gnome/desktop/interface" = with super.fonts.fontconfig; {
      "color-scheme" = "prefer-dark";
      "font-antialiasing" =
        if antialias then
          if (subpixel.rgba == "none")
          then "grayscale"
          else "rgba"
        else "none";
      "font-hinting" = builtins.replaceStrings [ "hint" ] [ "" ] hinting.style;
      "font-rgba-order" = subpixel.rgba;
    };
  };

  services.xsettingsd = {
    enable = true;
    settings = with config; {
      # When running, most GNOME/GTK+ applications prefer those settings
      # instead of *.ini files
      "Net/IconThemeName" = gtk.iconTheme.name;
      "Net/ThemeName" = gtk.theme.name;
      "Gtk/CursorThemeName" = xsession.pointerCursor.name;
    } // lib.optionalAttrs (super ? fonts.fontconfig) {
      # Applications like Java/Wine doesn't use Fontconfig settings,
      # but uses it from here
      "Xft/Antialias" = super.fonts.fontconfig.antialias;
      "Xft/Hinting" = super.fonts.fontconfig.hinting.enable;
      "Xft/HintStyle" = super.fonts.fontconfig.hinting.style;
      "Xft/RGBA" = super.fonts.fontconfig.subpixel.rgba;
    };
  };
}

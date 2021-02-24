{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    arandr
    bitwarden
    calibre
    chromium
    desktop-file-utils
    discord
    firefox
    gammastep
    gimp
    gnome3.evince
    gnome3.gnome-disk-utility
    gthumb
    inkscape
    kitty
    kotatogram-desktop
    libreoffice-fresh
    lxmenu-data
    ncdu
    pamixer-unstable
    pavucontrol
    pcmanfm
    peek
    qalculate-gtk
    smartmontools
    unstable.mcomix3
    unstable.xdragon
    xarchiver
    xdotool
    xorg.xdpyinfo
    xorg.xhost
    xorg.xkill
    xorg.xset
  ];

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "application/pdf" = "org.gnome.Evince.desktop";
      "image/gif" = "org.gnome.gThumb.desktop";
      "image/jpeg" = "org.gnome.gThumb.desktop";
      "image/png" = "org.gnome.gThumb.desktop";
      "inode/directory" = "pcmanfm.desktop";
      "text/html" = "firefox.desktop";
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
    };
  };
}

{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    arandr
    bitwarden
    calibre
    desktop-file-utils
    discord
    firefox
    gammastep
    gimp
    gnome3.evince
    gnome3.gnome-disk-utility
    google-chrome
    gthumb
    inkscape
    kitty
    libreoffice-fresh
    lxmenu-data
    ncdu
    open-browser
    pamixer-unstable
    pavucontrol
    pcmanfm
    peek
    qalculate-gtk
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
      "text/html" = "open-browser.desktop";
      "text/plain" = "emacs.desktop";
      "text/x-makefile" = "emacs.desktop";
      "x-scheme-handler/about" = "open-browser.desktop";
      "x-scheme-handler/http" = "open-browser.desktop";
      "x-scheme-handler/https" = "open-browser.desktop";
      "x-scheme-handler/unknown" = "open-browser.desktop";
    };
  };
}

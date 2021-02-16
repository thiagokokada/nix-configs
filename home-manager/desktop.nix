{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    bitwarden
    calibre
    chromium
    desktop-file-utils
    discord
    firefox
    gammastep
    gimp
    gnome3.baobab
    gnome3.evince
    gnome3.gnome-disk-utility
    gnome3.gnome-themes-standard
    gthumb
    inkscape
    kitty
    libreoffice-fresh
    lxmenu-data
    pavucontrol
    pcmanfm
    peek
    qalculate-gtk
    shared-mime-info
    smartmontools
    unstable.pulseeffects-legacy
    unstable.tdesktop
    unstable.xdragon
    xarchiver
    xdotool
    xorg.xdpyinfo
    xorg.xhost
    xorg.xkill
    xorg.xset
  ];
}

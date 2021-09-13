{ super, config, lib, pkgs, ... }:

let inherit (super.my) username;
in
{
  home.packages = with pkgs; [
    android-file-transfer
    arandr
    bitwarden
    calibre
    desktop-file-utils
    discord
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
    mcomix3
    ncdu
    open-browser
    pamixer-unstable
    pavucontrol
    pcmanfm
    peek
    qalculate-gtk
    vlc
    xarchiver
    xdotool
    xdragon
    xorg.xdpyinfo
    xorg.xhost
    xorg.xkill
    xorg.xset
    zoom-us
  ];

  programs.firefox = {
    enable = true;
    profiles.${username} = {
      settings = {
        # https://wiki.archlinux.org/title/Firefox#Hardware_video_acceleration
        "gfx.webrender.all" = true;
        "browser.quitShortcut.disabled" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.ffvpx.enabled" = true;
        "media.navigator.mediadatadecoder_vpx_enabled" = true;
      };
    };
  };

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

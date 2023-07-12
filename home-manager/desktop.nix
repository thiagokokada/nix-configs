{ pkgs, ... }:

{
  imports = [
    ./chromium.nix
    ./firefox.nix
  ];

  home.packages = with pkgs; [
    android-file-transfer
    audacious
    (calibre.override { unrarSupport = true; })
    (cinnamon.nemo-with-extensions.override { extensions = with cinnamon; [ nemo-fileroller ]; })
    desktop-file-utils
    gammastep
    gimp
    gnome.evince
    gnome.file-roller
    gnome.gnome-disk-utility
    gthumb
    inkscape
    libreoffice-fresh
    open-browser
    (mcomix.override { unrarSupport = true; })
    pavucontrol
    pinta
    qalculate-gtk
    vlc
    xclip
    xdotool
    xdragon
    xorg.xdpyinfo
    xorg.xhost
    xorg.xkill
    xorg.xset
    zoom-us
  ];

  services = {
    easyeffects.enable = true;
    udiskie = {
      enable = true;
      tray = "always";
    };
  };

  xdg = {
    # Some applications like to overwrite this file, so let's just force it
    configFile."mimeapps.list".force = true;

    mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "org.gnome.Evince.desktop";
        "image/gif" = "org.gnome.gThumb.desktop";
        "image/jpeg" = "org.gnome.gThumb.desktop";
        "image/png" = "org.gnome.gThumb.desktop";
        "inode/directory" = "nemo.desktop";
        "text/html" = "open-browser.desktop";
        "text/plain" = "emacs.desktop";
        "text/x-makefile" = "emacs.desktop";
        "x-scheme-handler/about" = "open-browser.desktop";
        "x-scheme-handler/http" = "open-browser.desktop";
        "x-scheme-handler/https" = "open-browser.desktop";
        "x-scheme-handler/unknown" = "open-browser.desktop";
      };
    };

    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}

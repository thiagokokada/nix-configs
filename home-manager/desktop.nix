{ super, config, lib, pkgs, ... }:

{
  imports = [ ./firefox.nix ];

  home.packages = with pkgs; [
    android-file-transfer
    arandr
    (calibre.override { unrarSupport = true; })
    desktop-file-utils
    discord
    gammastep
    gimp
    gnome.evince
    gnome.file-roller
    gnome.gnome-disk-utility
    gnome.nautilus
    google-chrome
    gthumb
    inkscape
    kitty
    libreoffice-fresh
    lxmenu-data
    (mcomix3.override { unrarSupport = true; })
    open-browser
    pamixer
    pavucontrol
    peek
    qalculate-gtk
    unstable.bitwarden
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

  programs.zsh.shellAliases = {
    copy = "${pkgs.xclip}/bin/xclip -selection c";
    paste = "${pkgs.xclip}/bin/xclip -selection c -o";
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
        "inode/directory" = "org.gnome.Nautilus.desktop";
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

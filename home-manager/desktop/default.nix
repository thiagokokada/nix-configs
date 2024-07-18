{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./chromium.nix
    ./dunst.nix
    ./firefox.nix
    ./gammastep.nix
    ./hyprland
    ./i3
    ./kitty.nix
    ./mpv
    ./nixgl.nix
    ./sway
    ./theme
    ./wezterm.nix
    ./xterm.nix
  ];

  options.home-manager.desktop = {
    enable = lib.mkEnableOption "desktop config";
    defaultEditor = lib.mkOption {
      type = lib.types.str;
      description = ''
        Default editor to be used.

        Should allow starting programs as parameter.
      '';
      default = lib.getExe config.programs.neovim.finalPackage;
    };
    defaultTerminal = lib.mkOption {
      type = lib.types.str;
      description = ''
        Default terminal emulator to be used.

        Should allow starting programs as parameter.
      '';
      default = "${lib.getExe config.programs.wezterm.package} start";
    };
  };

  config = lib.mkIf config.home-manager.desktop.enable {
    home = {
      # Disable keyboard management via HM
      keyboard = null;

      packages = with pkgs; [
        android-file-transfer
        audacious
        (calibre.override { unrarSupport = true; })
        (cinnamon.nemo-with-extensions.override { extensions = with cinnamon; [ nemo-fileroller ]; })
        desktop-file-utils
        ffmpeg
        evince
        file-roller
        gammastep
        gimp
        gnome-disk-utility
        gthumb
        inkscape
        libreoffice-fresh
        open-browser
        (mcomix.override { unrarSupport = true; })
        pamixer
        pavucontrol
        playerctl
        pinta
        qalculate-gtk
        vlc
        zoom-us
      ];

      sessionVariables = {
        # Workaround issues in e.g.: Firefox
        GTK_IM_MODULE = lib.mkDefault "xim";
        QT_IM_MODULE = lib.mkDefault "xim";
      };
    };

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
          "text/plain" = "nvim.desktop";
          "text/x-makefile" = "nvim.desktop";
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
  };
}

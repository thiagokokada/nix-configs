{
  config,
  pkgs,
  lib,
  osConfig,
  ...
}:

let
  cfg = config.home-manager.desktop;
in
{
  imports = [
    ./chromium.nix
    ./dunst.nix
    ./firefox.nix
    ./gammastep.nix
    ./kitty.nix
    ./mpv
    ./nixgl.nix
    ./theme
    ./wayland
    ./wezterm.nix
    ./x11
    ./xterm.nix
  ];

  options.home-manager.desktop = {
    enable = lib.mkEnableOption "desktop config";
    default = {
      browser = lib.mkOption {
        type = lib.types.str;
        description = "Default web browser to be used.";
        default = lib.getExe config.programs.firefox.finalPackage;
      };
      editor = lib.mkOption {
        type = lib.types.str;
        description = "Default editor to be used.";
        default = lib.getExe config.programs.neovim.finalPackage;
      };
      fileManager = lib.mkOption {
        type = lib.types.str;
        description = "Default file manager to be used.";
        default = "${cfg.default.terminal} -- ${lib.getExe config.programs.yazi.package}";
      };
      terminal = lib.mkOption {
        type = lib.types.str;
        description = ''
          Default terminal emulator to be used.

          Should allow starting programs as parameter.
        '';
        # TODO: switch back to wezterm once a new release is created
        default = lib.getExe config.programs.kitty.package;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      keyboard =
        let
          osKeyboard = osConfig.services.xserver.xkb or { };
        in
        {
          layout = lib.mkDefault (osKeyboard.layout or null);
          variant = lib.mkDefault (osKeyboard.variant or null);
          options = lib.mkDefault (lib.splitString "," (osKeyboard.options or ""));
        };

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

    services.udiskie.enable = true;

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

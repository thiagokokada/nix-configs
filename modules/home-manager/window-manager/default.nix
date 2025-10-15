{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.home-manager.window-manager;
in
{
  imports = [
    ./dunst.nix
    ./gammastep.nix
    ./theme
    ./wayland
    ./x11
  ];

  options.home-manager.window-manager = {
    enable = lib.mkEnableOption "window manager config";
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
      volumeControl = lib.mkOption {
        type = lib.types.str;
        description = "Default volume control to be used.";
        default = lib.getExe pkgs.pwvucontrol;
      };
      terminal = lib.mkOption {
        type = lib.types.str;
        description = ''
          Default terminal emulator to be used.

          Should allow starting programs as parameter.
        '';
        default = lib.getExe config.programs.kitty.package;
      };
    };
    systemd.service = {
      # Use exponential restart
      # https://enotty.pipebreaker.pl/posts/2024/01/how-systemd-exponential-restart-delay-works/
      RestartSec = lib.mkOption {
        type = lib.types.str;
        description = "How long to wait between restarts.";
        default = "250ms";
      };
      RestartSteps = lib.mkOption {
        type = lib.types.int;
        description = "Number of steps to take to increase the interval of auto-restarts.";
        default = 5;
      };
      RestartMaxDelaySec = lib.mkOption {
        type = lib.types.str;
        description = "Longest time to sleep before restarting a service as the interval goes up.";
        default = "5s";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      desktop-file-utils
      evince
      file-roller
      gnome-disk-utility
      gthumb
      (nemo-with-extensions.override { extensions = [ nemo-fileroller ]; })
      pamixer
      pwvucontrol
      playerctl
      qalculate-gtk
    ];

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
          "text/html" = "firefox.desktop";
          "text/plain" = "nvim.desktop";
          "text/x-makefile" = "nvim.desktop";
          "x-scheme-handler/about" = "firefox.desktop";
          "x-scheme-handler/http" = "firefox.desktop";
          "x-scheme-handler/https" = "firefox.desktop";
          "x-scheme-handler/unknown" = "firefox.desktop";
        };
      };

      userDirs = {
        enable = true;
        createDirectories = true;
      };
    };
  };
}

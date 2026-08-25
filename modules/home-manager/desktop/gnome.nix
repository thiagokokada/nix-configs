{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.home-manager.desktop.gnome;
  extensions = with pkgs.gnomeExtensions; [
    appindicator
    caffeine
    dash-to-dock
    hibernate-power-menu
  ];
in
{
  options.home-manager.desktop.gnome.enable = lib.mkEnableOption "GNOME config";

  config = lib.mkIf cfg.enable {
    home.packages = extensions;

    # IBus 1.5.33+ no longer loads the locale's standard Compose table
    # implicitly.  Keep the usual dead-key sequences available, including
    # dead_diaeresis + Space producing a literal double quote.
    # https://bugs.debian.org/1098736
    home.file.".XCompose".text = lib.mkDefault ''
      include "%L"
    '';

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };

      "org/gnome/desktop/input-sources" = {
        xkb-options = [ "caps:escape" ];
      };

      "org/gnome/desktop/wm/preferences" = {
        button-layout = "appmenu:minimize,maximize,close";
      };

      "org/gnome/desktop/wm/keybindings" = {
        # Unbind Ctrl+Space/Ctrl+Shift+Space to change keyboard layout
        switch-input-source = lib.hm.gvariant.mkEmptyArray lib.hm.gvariant.type.string;
        switch-input-source-backward = lib.hm.gvariant.mkEmptyArray lib.hm.gvariant.type.string;
      };

      "org/gnome/shell" = {
        enabled-extensions = map (extension: extension.extensionUuid) extensions;
      };

      "org/gnome/settings-daemon/plugins/power" = {
        ambient-enabled = false;
      };
    };
  };
}

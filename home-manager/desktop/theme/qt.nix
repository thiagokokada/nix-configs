{ config, pkgs, lib, ... }:

{
  options.home-manager.desktop.theme.qt.enable = lib.mkEnableOption "Qt theme config" // {
    default = config.home-manager.desktop.theme.enable;
  };

  config = lib.mkIf config.home-manager.desktop.theme.qt.enable {
    # TODO: remove after this PR is merged
    # https://github.com/nix-community/home-manager/pull/4579
    home.sessionVariables =
      let
        inherit (config.home) profileDirectory;
        qtVersions = with pkgs; [ qt5 qt6 ];
        makeQtPath = prefix: lib.concatStringsSep ":"
          (map (qt: "${profileDirectory}/${qt.qtbase.${prefix}}") qtVersions);
      in
      {
        QT_PLUGIN_PATH = "$QT_PLUGIN_PATH\${QT_PLUGIN_PATH:+:}${makeQtPath "qtPluginPrefix"}";
        QML2_IMPORT_PATH = "$QML2_IMPORT_PATH\${QML2_IMPORT_PATH:+:}${makeQtPath "qtQmlPrefix"}";
      };

    qt = {
      enable = true;
      platformTheme = "qtct";
      style.name = "kvantum";
    };

    xdg.configFile = {
      "Kvantum/kvantum.kvconfig".text = lib.generators.toINI { } {
        General.theme = "Nordic-bluish-solid";
      };
      "Kvantum" = {
        source = "${pkgs.nordic}/share/Kvantum";
        recursive = true;
      };
      "qt5ct/qt5ct.conf".text = lib.generators.toINI { } {
        Appearance = {
          style = "kvantum-dark";
          icon_theme = config.gtk.iconTheme.name;
          standard_dialogs = "gtk3";
        };
        Interface = {
          activate_item_on_single_click = 0;
          double_click_interval = 400;
          dialog_buttons_have_icons = 1;
          wheel_scroll_lines = 3;
        };
        Fonts = {
          # Noto Sans Mono 10
          fixed = ''@Variant(\0\0\0@\0\0\0\x1c\0N\0o\0t\0o\0 \0S\0\x61\0n\0s\0 \0M\0o\0n\0o@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)'';
          # Noto Sans 10
          general = ''@Variant(\0\0\0@\0\0\0\x12\0N\0o\0t\0o\0 \0S\0\x61\0n\0s@$\0\0\0\0\0\0\xff\xff\xff\xff\x5\x1\0\x32\x10)'';
        };
      };
      "qt6ct/qt6ct.conf".text = config.xdg.configFile."qt5ct/qt5ct.conf".text;
    };
  };
}

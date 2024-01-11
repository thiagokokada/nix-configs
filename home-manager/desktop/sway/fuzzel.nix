{ config, lib, ... }:

{
  options.home-manager.desktop.sway.fuzzel.enable = lib.mkEnableOption "Fuzzel config" // {
    default = config.home-manager.desktop.sway.enable;
  };

  config = lib.mkIf config.home-manager.desktop.sway.fuzzel.enable {
    programs.fuzzel = {
      enable = true;
      settings = with config.home-manager.desktop.theme.fonts; {
        main = {
          font = "${gui.name}:style=regular:size=14";
          terminal = config.home-manager.desktop.defaultTerminal;
          icon-theme = config.gtk.iconTheme.name;
          lines = 15;
          horizontal-pad = 10;
          vertical-pad = 10;
          line-height = 28;
        };
        colors = with config.home-manager.desktop.theme.colors; let
          fixColor = color: "${lib.removePrefix "#" color}ff";
        in
        {
          background = fixColor base00;
          border = fixColor base00;
          text = fixColor base05;
          selection = fixColor base0D;
          selection-text = fixColor base00;
          selection-match = fixColor base08;
        };
        key-bindings = {
          delete-line = "none";
          delete-prev-word = "Mod1+BackSpace Control+BackSpace Control+w";
          prev = "Up Control+p Control+k";
          next = "Down Control+n Control+j";
        };
      };
    };
  };
}

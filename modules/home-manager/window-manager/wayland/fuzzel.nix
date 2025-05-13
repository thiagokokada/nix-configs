{ config, lib, ... }:

let
  cfg = config.home-manager.window-manager.wayland.fuzzel;
in
{
  options.home-manager.window-manager.wayland.fuzzel.enable = lib.mkEnableOption "Fuzzel config" // {
    default = config.home-manager.window-manager.wayland.enable;
  };

  config = lib.mkIf cfg.enable {
    programs.fuzzel = {
      enable = true;
      settings = with config.home-manager.window-manager.theme.fonts; {
        main = {
          inherit (config.home-manager.window-manager.default) terminal;
          font = "${gui.name}:style=regular:size=14";
          icon-theme = config.gtk.iconTheme.name;
          lines = 15;
          horizontal-pad = 10;
          vertical-pad = 10;
          line-height = 28;
        };
        colors =
          with config.home-manager.window-manager.theme.colors;
          let
            fixColor = color: "${lib.removePrefix "#" color}ff";
          in
          {
            background = fixColor base00;
            border = fixColor base00;
            input = fixColor base05;
            placeholder = fixColor base05;
            prompt = fixColor base05;
            selection = fixColor base0D;
            selection-match = fixColor base08;
            selection-text = fixColor base00;
            text = fixColor base05;
          };
        key-bindings = {
          # Unmap delete-line-forward since its Control+k mapping conflicts
          # with custom prev mapping, and also unmap delete-line-backward for
          # consistency
          delete-line-backward = "none";
          delete-line-forward = "none";
          prev = "Up Control+p Control+k";
          next = "Down Control+n Control+j";
        };
      };
    };
  };
}

{ config, lib, pkgs, ... }:

{
  programs.rofi = {
    enable = true;
    terminal = "${config.programs.kitty.package}/bin/kitty";
    package = with pkgs; rofi.override { plugins = [ rofi-calc rofi-emoji ]; };
    font = with config.theme.fonts; "${gui.package} 14";
    theme =
      let l = config.lib.formats.rasi.mkLiteral;
      in
      with config.theme.colors; {
        "*" = {
          background-color = l base00;
          border-color = l base01;
          text-color = l base05;
          spacing = 0;
          width = l "512px";
        };

        inputbar = {
          border = l "0 0 1px 0";
          children = map l [ "prompt" "entry" ];
        };

        prompt = {
          padding = l "16px";
          border = l "0 1px 0 0";
        };

        textbox = {
          background-color = l base01;
          border = l "0 0 1px 0";
          border-color = l base00;
          padding = l "8px 16px";
        };

        entry = { padding = l "16px"; };

        listview = {
          cycle = true;
          margin = l "0 0 -1px 0";
          scrollbar = false;
        };

        element = {
          border = l "2px";
          border-color = l base00;
          padding = l "8px";
        };

        element-icon = {
          size = l "28px";
          border = l "0 4px";
          border-color = l base00;
        };

        "element selected" = {
          border-color = l base0D;
          color = l base00;
        };
      };

    extraConfig = {
      show-icons = true;
      modi = "drun,emoji,ssh";
      kb-row-up = "Up,Control+k";
      kb-row-down = "Down,Control+j";
      kb-accept-entry = "Control+m,Return,KP_Enter";
      kb-remove-to-eol = "Control+Shift+e";
      kb-mode-next = "Shift+Right,Control+Tab";
      kb-mode-previous = "Shift+Left,Control+Shift+Tab";
      kb-remove-char-back = "BackSpace";
    };
  };
}

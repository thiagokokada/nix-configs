{ ... }:

{
  programs.helix = {
    enable = true;

    settings = {
      theme = "onedark";

      editor.statusline = {
        left = [ "mode" "spinner" ];
        center = [ "file-name" ];
        right = [ "diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type" ];
        separator = "│";
        mode.normal = "NORMAL";
        mode.insert = "INSERT";
        mode.select = "SELECT";
      };
    };
  };
}

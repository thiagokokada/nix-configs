{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.home-manager.editor.helix.enable = lib.mkEnableOption "Helix editor config" // {
    default = config.home-manager.editor.enable;
  };

  config = lib.mkIf config.home-manager.editor.helix.enable {
    programs.helix = {
      enable = true;
      package = pkgs.evil-helix;

      settings = {
        theme = "tokyonight";

        editor = {
          soft-wrap.enable = true;
          statusline = {
            left = [
              "mode"
              "spinner"
            ];
            center = [ "file-name" ];
            right = [
              "diagnostics"
              "selections"
              "position"
              "file-encoding"
              "file-line-ending"
              "file-type"
            ];
            separator = "│";
            mode.normal = "NORMAL";
            mode.insert = "INSERT";
            mode.select = "SELECT";
          };
        };

        keys = {
          normal = {
            space.space = "file_picker";
            C-h = "select_prev_sibling";
            C-j = "shrink_selection";
            C-k = "expand_selection";
            C-l = "select_next_sibling";
          };

          select = {
            # Escape the madness! No more fighting with the cursor! Or with multiple cursors!
            esc = [
              "collapse_selection"
              "keep_primary_selection"
              "normal_mode"
            ];
          };
        };
      };
    };
  };
}

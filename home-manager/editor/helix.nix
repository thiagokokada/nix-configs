{ config, lib, pkgs, flake, ... }:

{
  options.home-manager.editor.helix.enable = lib.mkEnableOption "Helix editor config" // {
    default = config.home-manager.editor.enable;
  };

  config = lib.mkIf config.home-manager.editor.helix.enable {
    programs.helix = {
      enable = true;
      package = flake.inputs.evil-helix.packages.${pkgs.system}.helix;

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

        # inspired by https://github.com/LGUG2Z/helix-vim/
        keys = {
          normal = {
            space.space = "file_picker";
            C-h = "select_prev_sibling";
            C-j = "shrink_selection";
            C-k = "expand_selection";
            C-l = "select_next_sibling";

            # Clipboards over registers ye ye
            d = [ "yank_main_selection_to_clipboard" "delete_selection" ];
            x = [ "yank_main_selection_to_clipboard" "delete_selection" ];
            y = [ "yank_main_selection_to_clipboard" "normal_mode" "flip_selections" "collapse_selection" ];
            Y = [ "extend_to_line_bounds" "yank_main_selection_to_clipboard" "goto_line_start" "collapse_selection" "normal_mode" ];
            p = "replace_selections_with_clipboard"; # No life without this
            P = "paste_clipboard_before";

            # Escape the madness! No more fighting with the cursor! Or with multiple cursors!
            esc = [ "collapse_selection" "keep_primary_selection" "normal_mode" ];
          };
        };
      };
    };
  };
}

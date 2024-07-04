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
        theme = "tokyonight";

        editor.statusline = {
          left = [ "mode" "spinner" ];
          center = [ "file-name" ];
          right = [ "diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type" ];
          separator = "│";
          mode.normal = "NORMAL";
          mode.insert = "INSERT";
          mode.select = "SELECT";
        };

        keys = {
          normal = {
            space.space = "file_picker";
          };
        };
      };
    };
  };
}

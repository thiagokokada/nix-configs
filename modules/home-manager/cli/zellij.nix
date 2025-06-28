{ config, lib, ... }:

{
  options.home-manager.cli.zellij.enable = lib.mkEnableOption "Zellij config" // {
    default = config.home-manager.cli.enable;
  };

  config = lib.mkIf config.home-manager.cli.zellij.enable {
    programs.zellij = {
      enable = true;
      settings = {
        default_mode = "normal";
        show_startup_tips = false;
        show_release_notes = false;
      };
    };
  };
}

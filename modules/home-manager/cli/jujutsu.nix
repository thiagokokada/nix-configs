{ config, lib, ... }:

let
  cfg = config.home-manager.cli.jujutsu;
in
{
  options.home-manager.cli.jujutsu = {
    enable = lib.mkEnableOption "Jujutsu config" // {
      default = config.home-manager.cli.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;
      settings = {
        ui.editor = "nvim";
        user = {
          name = config.meta.fullname;
          email = config.meta.email;
        };
      };
    };
  };
}

{ config, pkgs, lib, ... }:

{
  options.home-manager.cli.htop.enable = lib.mkEnableOption "htop config" // {
    default = config.home-manager.cli.enable;
  };

  config = lib.mkIf config.home-manager.cli.htop.enable {
    programs.htop = {
      enable = true;
      package = pkgs.htop-vim;
      settings = {
        hide_userland_threads = true;
        color_scheme = 6;
      };
    };
  };
}

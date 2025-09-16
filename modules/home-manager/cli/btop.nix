{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.home-manager.cli.btop.enable = lib.mkEnableOption "btop config" // {
    default = config.home-manager.cli.enable;
  };

  config = lib.mkIf config.home-manager.cli.btop.enable {
    programs.btop = {
      enable = true;
      # https://github.com/aristocratos/btop
      settings = {
        color_theme = "${pkgs.btop}/share/btop/themes/dracula.theme";
        vim_keys = true;
        graph_symbol = "block";
        proc_gradient = false;
      };
    };
  };
}

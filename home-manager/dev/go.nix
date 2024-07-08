{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.home-manager.dev.go.enable = lib.mkEnableOption "Go config" // {
    default = config.home-manager.dev.enable;
  };

  config = lib.mkIf config.home-manager.dev.go.enable {
    programs.go = {
      enable = true;
      goBin = ".go/bin";
      goPath = ".go";
    };

    home = {
      packages = with pkgs; [ gopls ];
      sessionPath = [ config.home.sessionVariables.GOBIN ];
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:

let
  GOPATH = "${config.home.homeDirectory}/.go";
  GOBIN = "${GOPATH}/bin";
in
{
  options.home-manager.dev.go.enable = lib.mkEnableOption "Go config" // {
    default = config.home-manager.dev.enable;
  };

  config = lib.mkIf config.home-manager.dev.go.enable {
    programs.go = {
      enable = true;
      env = { inherit GOBIN GOPATH; };
    };

    home = {
      packages = with pkgs; [ gopls ];
      sessionPath = [ GOBIN ];
    };
  };
}

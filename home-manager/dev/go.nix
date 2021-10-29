{ config, ... }:

{
  programs.go = {
    enable = true;
    goBin = ".go/bin";
    goPath = ".go";
  };
  home.sessionPath = [ config.home.sessionVariables.GOBIN ];
}

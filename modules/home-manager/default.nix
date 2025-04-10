{ lib, ... }:

{
  imports = [
    ../shared
    ./cli
    ./crostini.nix
    ./darwin
    ./desktop
    ./dev
    ./editor
    ./meta
    ./nix
  ];

  home = {
    username = lib.mkDefault "thiagoko";
    homeDirectory = lib.mkDefault "/home/thiagoko";
    stateVersion = lib.mkDefault "25.05";
  };
}

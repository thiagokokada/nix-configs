{ flake, lib, ... }:

{
  imports = [
    flake.outputs.internal.sharedModules.default
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
    username = lib.mkOptionDefault "thiagoko";
    homeDirectory = lib.mkOptionDefault "/home/thiagoko";
    stateVersion = lib.mkOptionDefault "25.05";
  };
}

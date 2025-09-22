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
    ./window-manager
  ];

  options.home-manager = {
    hostName = lib.mkOption {
      description = "Hostname";
      type = lib.types.nullOr lib.types.str;
      default = null;
    };
  };

  config = {
    home = {
      username = lib.mkOptionDefault "thiagoko";
      homeDirectory = lib.mkOptionDefault "/home/thiagoko";
      stateVersion = lib.mkOptionDefault "25.05";
    };
  };
}

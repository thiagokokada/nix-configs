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
      description = "The hostname of the machine.";
      type = lib.types.str;
      default = "generic";
    };
  };

  config = {
    home = {
      username = lib.mkOptionDefault "thiagoko";
      homeDirectory = lib.mkOptionDefault "/home/thiagoko";
    };
  };
}

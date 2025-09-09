{ flake, ... }:

{
  imports = [
    flake.outputs.internal.sharedModules.default
    ./desktop
    ./dev
    ./games
    ./home.nix
    ./laptop
    ./nix
    ./server
    ./system
    ./window-manager
  ];
}

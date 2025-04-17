{ flake, ... }:

{
  imports = [
    flake.outputs.internal.sharedModules.default
    ./desktop
    ./games
    ./home.nix
    ./laptop
    ./nix
    ./server
    ./system
  ];
}

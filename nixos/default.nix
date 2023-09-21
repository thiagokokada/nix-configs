{ ... }:

{
  imports = [
    ./cross-compiling.nix
    ./desktop
    ./dev
    ./games
    ./home.nix
    ./laptop
    ./minimal.nix
    ./server
  ];
}

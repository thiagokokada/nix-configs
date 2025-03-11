{ flake, ... }:

{
  imports = [
    ../shared
    ./desktop
    ./games
    ./home.nix
    ./laptop
    ./nix
    ./server
    ./system
  ];

  nixpkgs.overlays = [ (import ../../overlays { inherit flake; }) ];
}

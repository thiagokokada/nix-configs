{ flake, ... }:

{
  imports = [
    ../modules
    ./desktop
    ./dev
    ./games
    ./home.nix
    ./laptop
    ./nix
    ./server
    ./system
  ];

  nixpkgs.overlays = [ (import ../overlays { inherit flake; }) ];
}

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

  nixpkgs.overlays = [ flake.outputs.overlays.default ];
}

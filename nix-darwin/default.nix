{ flake, ... }:

{
  imports = [
    ../modules
    ./cli.nix
    ./home.nix
    ./nix.nix
  ];

  nixpkgs.overlays = [ (import ../overlays { inherit flake; }) ];
}

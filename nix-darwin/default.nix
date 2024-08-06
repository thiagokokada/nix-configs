{ flake, ... }:

{
  imports = [
    ../modules
    ./cli.nix
    ./home.nix
    ./homebrew.nix
    ./nix.nix
  ];

  nixpkgs.overlays = [ (import ../overlays { inherit flake; }) ];
}

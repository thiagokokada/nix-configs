{ flake, ... }:

{
  imports = [
    ../modules
    ./cli.nix
    ./home.nix
    ./homebrew.nix
    ./nix
    ./system.nix
  ];

  nixpkgs.overlays = [ (import ../overlays { inherit flake; }) ];
}

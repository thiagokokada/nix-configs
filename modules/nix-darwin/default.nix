{ flake, ... }:

{
  imports = [
    ../shared
    ./cli.nix
    ./home.nix
    ./homebrew.nix
    ./nix
    ./system.nix
  ];

  nixpkgs.overlays = [ flake.outputs.overlays.default ];
}

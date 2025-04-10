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
}

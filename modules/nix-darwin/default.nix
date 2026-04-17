{ flake, ... }:

{
  imports = [
    flake.outputs.internal.sharedModules.default
    ./home.nix
    ./homebrew.nix
    ./nix
    ./system.nix
  ];
}

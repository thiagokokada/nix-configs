{ flake, ... }:

{
  imports = [
    flake.outputs.internal.sharedModules.default
    ./home.nix
    ./nix.nix
  ];
}

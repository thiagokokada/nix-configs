{ ... }:

{
  imports = [
    ./cli.nix
    ./locale.nix
    ./meta.nix
    ./system
    ./user.nix
    ../modules
  ];
}

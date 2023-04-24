{ pkgs, flake, ... }:

let
  inherit (flake) inputs;
in
{
  # Enable Flakes
  settings = import ./nix-conf.nix;

  # Set the $NIX_PATH entry for nixpkgs. This is necessary in
  # this setup with flakes, otherwise commands like `nix-shell
  # -p pkgs.htop` will keep using an old version of nixpkgs
  nixPath = [
    "nixpkgs=${inputs.nixpkgs}"
  ];
  # Same as above, but for `nix shell nixpkgs#htop`
  # FIXME: for non-free packages you need to use `nix shell --impure`
  registry = {
    nixpkgs.flake = inputs.nixpkgs;
  };
}

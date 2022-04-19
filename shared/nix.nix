{ pkgs, self, ... }:

let
  inherit (self) inputs;
in
{
  # Add wheel to Nix trusted users
  trustedUsers = [ "root" "@wheel" ];

  # Enable Flakes
  package = pkgs.nixFlakes;
  extraOptions = builtins.readFile ./nix.conf;

  # Set the $NIX_PATH entry for nixpkgs. This is necessary in
  # this setup with flakes, otherwise commands like `nix-shell
  # -p pkgs.htop` will keep using an old version of nixpkgs
  nixPath = [
    "nixpkgs=${inputs.nixpkgs}"
    "nixpkgs-unstable=${inputs.unstable}"
  ];
  # Same as above, but for `nix shell nixpkgs#htop`
  # FIXME: for non-free packages you need to use `nix shell --impure`
  registry = {
    nixpkgs.flake = inputs.nixpkgs;
    nixpkgs-unstable.flake = inputs.unstable;
  };
}

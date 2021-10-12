{ config, lib, pkgs, self, ... }:

let
  inherit (self) inputs;
in
{
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  nix = {
    trustedUsers = [ "root" "@wheel" ];
    # FIXME: doesn't seem to be working
    # https://github.com/LnL7/nix-darwin/issues/355
    # package = pkgs.nixFlakes;
    # extraOptions = ''
    #   experimental-features = nix-command flakes
    # '';

    # Set the $NIX_PATH entry for nixpkgs. This is necessary in
    # this setup with flakes, otherwise commands like `nix-shell
    # -p pkgs.htop` will keep using an old version of nixpkgs
    nixPath = [
      "nixpkgs=${inputs.nixpkgs}"
      "nixpkgs-unstable=${inputs.unstable}"
    ];
  };
}

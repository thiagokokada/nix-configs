{ config, lib, pkgs, self, ... }:

let
  inherit (self) inputs;
in
{
  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  environment.systemPackages = [
    (pkgs.writeScriptBin "nixFlakes" ''
      exec ${pkgs.nixUnstable}/bin/nix --experimental-features "nix-command flakes" "$@"
    '')
  ];

  nix = {
    trustedUsers = [ "root" "@wheel" ];
    package = pkgs.nixFlakes;
    # FIXME: doesn't seem to be working, so we are using nixFlakes instead
    # https://github.com/LnL7/nix-darwin/issues/355
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

{ lib, pkgs, ... }:

{
  # https://github.com/NixOS/nix/issues/7273
  auto-optimise-store = lib.mkIf (!pkgs.stdenv.isDarwin) true;
  experimental-features = [ "nix-command" "flakes" ];
}

{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  name = "nixpkgs-review-cage";

  src = with pkgs; substituteAll {
    src = ./nixpkgs-review-cage.sh;
    isExecutable = true;

    inherit coreutils;
    nix_cage = nix-cage;
    nixpkgs_review = nixpkgs-review;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/bin/nixpkgs-review*"

    runHook postInstall
  '';
}

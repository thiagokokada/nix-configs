{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  name = "nix-whereis";

  src = with pkgs; substituteAll {
    src = ./nix-whereis.sh;
    isExecutable = true;
    inherit coreutils which bash;
  };

  dontUnpack = true;

  installPhase = ''
    install -Dm755 "$src" "$out/bin/nix-whereis"
  '';
}

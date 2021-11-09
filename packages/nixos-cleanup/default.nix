{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  name = "nixos-cleanup";

  src = with pkgs; substituteAll {
    src = ./nixos-cleanup.sh;
    isExecutable = true;
    inherit findutils gnugrep bash;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/bin/nixos-cleanup"

    runHook postInstall
  '';
}

{ stdenvNoCC
, bash
, coreutils
, findutils
, gnugrep
, substituteAll
}:

stdenvNoCC.mkDerivation {
  name = "nixos-cleanup";

  src = substituteAll {
    src = ./nixos-cleanup.sh;
    isExecutable = true;
    inherit coreutils findutils gnugrep bash;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/bin/nixos-cleanup"

    runHook postInstall
  '';
}

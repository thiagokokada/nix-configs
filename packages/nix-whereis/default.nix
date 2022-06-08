{ stdenvNoCC
, bash
, coreutils
, substituteAll
, which
}:

stdenvNoCC.mkDerivation {
  name = "nix-whereis";

  src = substituteAll {
    src = ./nix-whereis.sh;
    isExecutable = true;
    inherit coreutils which bash;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/bin/nix-whereis"

    runHook postInstall
  '';
}

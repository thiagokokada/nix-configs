{ lib
, stdenvNoCC
, coreutils
, gawk
, findutils
, gnugrep
, home-manager
, nix
, shellcheck
, substituteAll
, isNixOS ? false
}:

stdenvNoCC.mkDerivation {
  name =
    if isNixOS
    then "nixos-cleanup"
    else "nix-cleanup";

  src = substituteAll {
    src = ./nix-cleanup.sh;
    isNixOS = if isNixOS then "1" else "0";
    path = lib.makeBinPath [
      coreutils
      findutils
      gawk
      gnugrep
      home-manager
      nix
    ];
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm0755 $src $out/bin/nix-cleanup

    runHook postInstall
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    ${lib.getExe shellcheck} $src

    runHook postCheck
  '';
}

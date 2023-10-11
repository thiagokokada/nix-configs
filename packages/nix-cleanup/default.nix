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

stdenvNoCC.mkDerivation (finalAttrs: {
  name =
    if isNixOS
    then "nixos-cleanup"
    else "nix-cleanup";

  src = substituteAll {
    src = ./nix-cleanup.sh;
    is_nixos = if isNixOS then "1" else "0";
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

    install -Dm0755 $src $out/bin/${finalAttrs.name}

    runHook postInstall
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    ${lib.getExe shellcheck} $src

    runHook postCheck
  '';
})

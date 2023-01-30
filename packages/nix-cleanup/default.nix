{ bash
, coreutils
, findutils
, gnugrep
, nix
, resholve
, substituteAll
, isNixOS ? false
}:

resholve.mkDerivation rec {
  pname =
    if isNixOS
    then "nixos-cleanup"
    else "nix-cleanup";

  version = "0.0.1";

  src = (substituteAll {
    src = ./nix-cleanup.sh;
    isNixOS = if isNixOS then "1" else "0";
  });

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/bin/${pname}"

    runHook postInstall
  '';

  solutions = {
    nix-whereis = {
      scripts = [ "bin/${pname}" ];
      interpreter = "${bash}/bin/bash";
      inputs = [ coreutils findutils gnugrep nix ];
      fake = {
        external = [
          "nixos-rebuild"
          # https://github.com/abathur/resholve/issues/29
          "sudo"
        ];
      };
      execer = [
        "cannot:${nix}/bin/nix-store"
        "cannot:${nix}/bin/nix-collect-garbage"
      ];
    };
  };
}

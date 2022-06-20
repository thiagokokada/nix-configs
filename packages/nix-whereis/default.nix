{ bash
, coreutils
, resholve
, which
}:

resholve.mkDerivation {
  pname = "nix-whereis";
  version = "0.0.1";

  src = ./nix-whereis.sh;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/bin/nix-whereis"

    runHook postInstall
  '';

  solutions = {
    nix-whereis = {
      scripts = [ "bin/nix-whereis" ];
      interpreter = "${bash}/bin/bash";
      inputs = [ coreutils which ];
    };
  };
}

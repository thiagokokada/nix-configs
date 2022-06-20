{ bash
, coreutils
, findutils
, gnugrep
, nix
, resholve
}:

resholve.mkDerivation {
  pname = "nixos-cleanup";
  version = "0.0.1";

  src = ./nixos-cleanup.sh;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 "$src" "$out/bin/nixos-cleanup"

    runHook postInstall
  '';

  solutions = {
    nix-whereis = {
      scripts = [ "bin/nixos-cleanup" ];
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

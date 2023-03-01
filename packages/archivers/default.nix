{ _7zz
, bash
, coreutils
, gnutar
, gzip
, pbzip2
, pigz
, rar
, resholve
, unzip
, xz
, zip
, zstd
}:

resholve.mkDerivation {
  pname = "archivers";
  version = "0.0.1";

  src = [
    ./archive.sh
    ./unarchive.sh
    ./lsarchive.sh
  ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    for _src in $src; do
      script_filename="$(stripHash $_src)"
      # remove .sh extension
      script_name="''${script_filename%.sh}"
      install -Dm755 "$_src" "$out/bin/$script_name"
    done

    runHook postInstall
  '';

  solutions = {
    archivers = {
      scripts = [
        "bin/archive"
        "bin/unarchive"
        "bin/lsarchive"
      ];
      interpreter = "${bash}/bin/bash";
      inputs = [
        _7zz
        coreutils
        gnutar
        gzip
        pbzip2
        pigz
        rar
        unzip
        xz
        zip
        zstd
      ];
      execer = [
        "cannot:${gzip}/bin/uncompress"
      ];
    };
  };
}

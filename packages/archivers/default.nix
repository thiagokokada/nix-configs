{ bash
, coreutils
, gnutar
, gzip
, p7zip
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
      ];
      interpreter = "${bash}/bin/bash";
      inputs = [
        coreutils
        gnutar
        gzip
        p7zip
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
        "cannot:${p7zip}/bin/7z"
        "cannot:${p7zip}/bin/7za"
      ];
    };
  };
}

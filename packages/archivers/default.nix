{ lib
, runCommand
, writeShellApplication
, _7zz
, coreutils
, gnutar
, gzip
, pbzip2
, pigz
, rar
, unzip
, xz
, zip
, zstd
}:

let
  runtimeInputs = [
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
  archive = writeShellApplication {
    name = "archive";
    text = lib.readFile ./archive.sh;
    inherit runtimeInputs;
  };
  unarchive = writeShellApplication {
    name = "unarchive";
    text = lib.readFile ./unarchive.sh;
    inherit runtimeInputs;
  };
  lsarchive = writeShellApplication {
    name = "lsarchive";
    text = lib.readFile ./lsarchive.sh;
    inherit runtimeInputs;
  };
in
runCommand "archivers" { } ''
  install ${archive}/bin/archive -Dt $out/bin
  install ${unarchive}/bin/unarchive -Dt $out/bin
  install ${lsarchive}/bin/lsarchive -Dt $out/bin
''

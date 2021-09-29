{ lib, stdenv, fetchurl, autoPatchelfHook }:

stdenv.mkDerivation rec {
  pname = "rar";
  version = "6.0.2";

  src = fetchurl {
    url = "https://www.rarlab.com/rar/rarlinux-x64-${version}.tar.gz";
    sha256 = "sha256-WAvrUGCgfwI51Mo/RYSSF0OLPPrTegUCuDEsnBeR9uQ=";
  };

  manSrc = fetchurl {
    url = "https://aur.archlinux.org/cgit/aur.git/plain/rar.1?h=rar&id=8e39a12e88d8a3b168c496c44c18d443c876dd10";
    name = "rar.1";
    sha256 = "sha256-93cSr9oAsi+xHUtMsUvICyHJe66vAImS2tLie7nt8Uw=";
  };

  dontBuild = true;

  buildInputs = [ stdenv.cc.cc.lib ];

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    install -Dm755 {rar,unrar} -t "$out/bin"
    install -Dm755 default.sfx -t "$out/lib"
    install -Dm644 {acknow.txt,license.txt} -t "$out/share/doc/rar"
    install -Dm644 rarfiles.lst -t "$out/etc"

    install -Dm644 ${manSrc} "$out/share/man/man1/rar.1"

    runHook postCheck
  '';

  meta = with lib; {
    description = "Utility for RAR archives";
    homepage = "https://www.rarlab.com/";
    license = licenses.unfree;
    maintainers = with maintainers; [ thiagokokada ];
    platforms = platforms.linux;
  };
}

{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    aria2
    coreutils
    curl
    dos2unix
    each
    jo
    jq
    moreutils
    netcat-gnu
    p7zip
    page
    pv
    rar
    ripgrep
    rlwrap
    tealdeer
    telnet
    tig
    unzip
    wget
    zip
  ] ++ lib.optionals (!stdenv.isDarwin) [
    unar
  ];
}

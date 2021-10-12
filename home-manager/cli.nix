{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    aria2
    coreutils
    curl
    daemonize
    dos2unix
    each
    gdu
    jo
    jq
    moreutils
    netcat-gnu
    p7zip
    page
    pv
    python3
    rar
    ripgrep
    rlwrap
    sloccount
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

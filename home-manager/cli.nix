{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    aria2
    binutils
    coreutils
    curl
    daemonize
    diffutils
    dos2unix
    dua
    each
    findutils
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

  programs.zsh.shellAliases = {
    ncdu = "${pkgs.dua}/bin/dua interactive";
  };
}

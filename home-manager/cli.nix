{ config, lib, pkgs, ... }:

let
  # fix conflict with gcc in darwin
  binutils = (lib.hiPrio pkgs.binutils);
in
{
  home.packages = with pkgs; [
    aria2
    bat
    bc
    bind
    binutils
    coreutils
    curl
    daemonize
    diffutils
    dos2unix
    dua
    each
    file
    findutils
    gcal
    gnumake
    gnused
    inetutils
    ix
    jo
    jq
    lsof
    mediainfo
    moreutils
    netcat-gnu
    openssl
    ouch
    p7zip
    page
    pipe-rename
    pv
    python3
    rar
    ripgrep
    rlwrap
    tealdeer
    tig
    tokei
    unzip
    wget
    zip
  ];

  programs.zsh.shellAliases = {
    # For muscle memory...
    cal = "${pkgs.gcal}/bin/gcal";
    ncdu = "${pkgs.dua}/bin/dua interactive";
    sloccount = "${pkgs.tokei}/bin/tokei";
  };
}

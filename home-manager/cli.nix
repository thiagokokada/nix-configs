{ config, lib, pkgs, ... }:

let
  # fix conflict with gcc in darwin
  binutils = (lib.hiPrio pkgs.binutils);
in
{
  home.packages = with pkgs; [
    _7zz
    aria2
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
    page
    pipe-rename
    pv
    python3
    ripgrep
    rlwrap
    tealdeer
    tig
    tokei
    unar
    unzip
    wget
    zip
  ];

  programs = {
    bat = {
      enable = true;
      extraPackages = with pkgs.bat-extras; [ batdiff batman batgrep batwatch ];
    };
    zsh.shellAliases = {
      # For muscle memory...
      cal = "${pkgs.gcal}/bin/gcal";
      ncdu = "${pkgs.dua}/bin/dua interactive";
      sloccount = "${pkgs.tokei}/bin/tokei";
    };
  };
}

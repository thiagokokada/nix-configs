{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    aria2
    (lib.hiPrio binutils) # fix conflict with gcc in darwin
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
    tealdeer
    telnet
    tig
    tokei
    unzip
    wget
    zip
  ] ++ lib.optionals (!stdenv.isDarwin) [
    unar
  ];

  programs.zsh.shellAliases = {
    # For muscle memory...
    ncdu = "${pkgs.dua}/bin/dua interactive";
    sloccount = "${pkgs.scc}/bin/tokei";
  };
}

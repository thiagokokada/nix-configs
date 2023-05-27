{ pkgs, ... }:

{
  home.packages = with pkgs; [
    _7zz
    aria2
    bc
    bind
    coreutils
    curl
    daemonize
    diffutils
    dos2unix
    dua
    each
    ffmpeg
    file
    findutils
    gcal
    gnumake
    gnused
    ix
    jq
    lsof
    mediainfo
    netcat-gnu
    ouch
    pv
    ripgrep
    rlwrap
    tealdeer
    tig
    tokei
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
      archive = "${pkgs.ouch}/bin/ouch compress";
      unarchive = "${pkgs.ouch}/bin/ouch decompress";
      lsarchive = "${pkgs.ouch}/bin/ouch list";
      cal = "${pkgs.gcal}/bin/gcal";
      ncdu = "${pkgs.dua}/bin/dua interactive";
      sloccount = "${pkgs.tokei}/bin/tokei";
    };
  };
}

{ config, pkgs, lib, ... }:

{
  imports = [
    ./git.nix
    ./htop.nix
    ./irssi.nix
    ./nnn.nix
    ./ssh.nix
    ./tmux.nix
    ./zsh.nix
  ];

  options.home-manager.cli.enable = lib.mkDefaultOption "CLI config";

  config = lib.mkIf config.home-manager.cli.enable {
    home.packages = with pkgs; [
      _7zz
      aria2
      bc
      bind.dnsutils
      coreutils
      curl
      curlie
      dialog
      diffutils
      dos2unix
      dua
      each
      file
      findutils
      gawk
      gcal
      gnugrep
      gnumake
      gnused
      inetutils
      ix
      jq
      less
      lsof
      mediainfo
      netcat-gnu
      ouch
      page
      procps
      pv
      python3
      ripgrep
      rlwrap
      tealdeer
      tig
      tokei
      wget
    ];

    programs = {
      bat = {
        enable = true;
        extraPackages = with pkgs.bat-extras; [ batdiff batman batgrep batwatch ];
      };
      eza = {
        enable = true;
        enableAliases = true;
        git = true;
      };
      zsh.shellAliases = {
        # For muscle memory...
        archive = "${pkgs.ouch}/bin/ouch compress";
        unarchive = "${pkgs.ouch}/bin/ouch decompress";
        lsarchive = "${pkgs.ouch}/bin/ouch list";
        cal = "${pkgs.gcal}/bin/gcal";
        http = "${pkgs.curlie}/bin/curlie";
        ncdu = "${pkgs.dua}/bin/dua interactive";
        sloccount = "${pkgs.tokei}/bin/tokei";
      };
    };
  };
}

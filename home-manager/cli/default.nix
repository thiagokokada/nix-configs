{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.home-manager.cli;
in
{
  imports = [
    ./git.nix
    ./htop.nix
    ./irssi.nix
    ./nixpkgs.nix
    ./ssh
    ./tmux.nix
    ./yazi.nix
    ./zsh
  ];

  options.home-manager.cli = {
    enable = lib.mkEnableOption "CLI config" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        _7zz
        aria2
        bc
        bind.dnsutils
        curl
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
        hyperfine
        ix
        jq
        less
        lsof
        mediainfo
        ouch
        page
        procps
        pv
        ripgrep
        rlwrap
        tokei
        wget
      ];

      shellAliases = {
        # For muscle memory...
        archive = "${lib.getExe pkgs.ouch} compress";
        unarchive = "${lib.getExe pkgs.ouch} decompress";
        lsarchive = "${lib.getExe pkgs.ouch} list";
        cal = lib.getExe pkgs.gcal;
        ncdu = "${lib.getExe pkgs.dua} interactive";
        sloccount = lib.getExe pkgs.tokei;
      };
    };
  };
}

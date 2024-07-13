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
    ./nnn.nix
    ./ssh.nix
    ./tmux.nix
    ./zsh.nix
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
        python3
        ripgrep
        rlwrap
        tealdeer
        time
        tokei
        wget
      ];

      shellAliases = {
        # For muscle memory...
        archive = "${lib.getExe pkgs.ouch} compress";
        lsarchive = "${lib.getExe pkgs.ouch} list";
        unarchive = "${lib.getExe pkgs.ouch} decompress";
        cal = lib.getExe pkgs.gcal;
        ncdu = "${lib.getExe pkgs.dua} interactive";
        sloccount = lib.getExe pkgs.tokei;
        time = lib.getExe pkgs.time; # GNU time with more features, e.g.: time -v
      };
    };
  };
}

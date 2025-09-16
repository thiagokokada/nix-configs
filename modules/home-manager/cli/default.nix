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
    ./btop.nix
    ./git.nix
    ./htop.nix
    ./irssi.nix
    ./jujutsu.nix
    ./nixpkgs.nix
    ./ssh
    ./tmux.nix
    ./yazi.nix
    ./zellij.nix
    ./zsh
  ];

  options.home-manager.cli = {
    enable = lib.mkEnableOption "CLI config" // {
      default = true;
    };
    # Do not forget to set 'Hack Nerd Mono Font' as the terminal font
    icons.enable = lib.mkEnableOption "terminal icons" // {
      default = config.home-manager.desktop.enable || config.home-manager.darwin.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        _7zz
        bc
        bind.dnsutils
        curl
        dialog
        diffutils
        dos2unix
        dua
        each
        ffmpeg
        file
        findutils
        gawk
        gcal
        gnugrep
        gnumake
        gnused
        hyperfine
        lsof
        mediainfo
        ouch
        page
        procps
        pv
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

    programs = {
      aria2.enable = true;
      jq.enable = true;
      less.enable = true;
      ripgrep.enable = true;
    };
  };
}

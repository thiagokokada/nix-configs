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
        dos2unix
        dua
        each
        ffmpeg
        file
        hyperfine
        lsof
        mediainfo
        ouch
        page
        pv
        rlwrap
        tokei
        watch
        wget
      ];

      shellAliases = {
        # For muscle memory...
        archive = "${lib.getExe pkgs.ouch} compress";
        unarchive = "${lib.getExe pkgs.ouch} decompress";
        lsarchive = "${lib.getExe pkgs.ouch} list";
        ncdu = "${lib.getExe pkgs.dua} interactive";
        sloccount = lib.getExe pkgs.tokei;
      };
    };

    programs = {
      aria2.enable = true;
      jq.enable = true;
      less = {
        enable = true;
        # Fix issue with Kitty
        # https://github.com/NixOS/nixpkgs/pull/490763
        package = pkgs.less.overrideAttrs (_: rec {
          version = "692";
          src = pkgs.fetchurl {
            url = "https://www.greenwoodsoftware.com/less/less-${version}.tar.gz";
            hash = "sha256-YTAPYDeY7PHXeGVweJ8P8/WhrPB1pvufdWg30WbjfRQ=";
          };
        });
        options = {
          chop-long-lines = true;
          hilite-search = true;
          hilite-unread = true;
          ignore-case = true;
          LONG-PROMPT = true;
          no-init = true;
          RAW-CONTROL-CHARS = true;
          wheel-lines = 3;
          window = 4;
        };
      };
      ripgrep.enable = true;
    };
  };
}

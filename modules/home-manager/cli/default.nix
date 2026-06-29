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
    ./gnu.nix
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
        ouch-rar
        page
        pv
        rlwrap
        tokei
        viu
        watch
        wget
      ];

      sessionVariables = {
        # https://felipec.wordpress.com/2021/06/05/adventures-with-man-color/
        MANPAGER = "less --use-color -Dd+r -Du+b";
      };
      sessionPath = [ "$HOME/.local/bin" ];

      shellAliases = {
        # For muscle memory...
        archive = "${lib.getExe pkgs.ouch-rar} compress";
        unarchive = "${lib.getExe pkgs.ouch-rar} decompress";
        lsarchive = "${lib.getExe pkgs.ouch-rar} list";
        ncdu = "${lib.getExe pkgs.dua} interactive";
        sloccount = lib.getExe pkgs.tokei;
      };
    };

    programs = {
      aria2.enable = true;
      fd.enable = true;
      jq.enable = true;
      less = {
        enable = true;
        options = {
          chop-long-lines = true;
          hilite-search = true;
          hilite-unread = true;
          ignore-case = true;
          LONG-PROMPT = true;
          mouse = true;
          no-init = true;
          RAW-CONTROL-CHARS = true;
          wheel-lines = 3;
          window = 4;
        };
      };
      man =
        let
          mandocWrapped =
            with pkgs;
            symlinkJoin {
              name = "${mandoc.name}-wrapped";
              paths = [ mandoc ];
              nativeBuildInputs = [ makeWrapper ];
              postBuild = ''
                rm -f "$out/bin/man"
                makeWrapper ${lib.getExe mandoc} "$out/bin/man" \
                  --run 'if [ -t 1 ]; then cols="$(${lib.getExe' ncurses "tput"} cols 2>/dev/null || true)"; if [ -n "$cols" ]; then set -- -O "width=$cols" "$@"; fi; fi'
              '';
            };
        in
        {
          generateCaches = true;
          package = mandocWrapped;
          man-db.enable = false;
          mandoc.enable = true;
        };
      ripgrep.enable = true;
    };
  };
}

{ config, lib, pkgs, flake, ... }:

let
  inherit (flake) inputs;
  cfg = config.home-manager.cli.nnn;
in
{
  options.home-manager.cli.nnn = {
    enable = lib.mkEnableOption "nnn config" // {
      default = config.home-manager.cli.enable;
    };
    # Do not forget to set 'Hack Nerd Mono Font' as the terminal font
    enableIcons = lib.mkEnableOption "icons" // {
      default = config.home-manager.desktop.enable || config.home-manager.darwin.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = lib.optionals cfg.enableIcons [
      config.home-manager.desktop.theme.fonts.symbols.package
    ];

    programs.nnn = {
      enable = true;
      package = pkgs.nnn.override { withNerdIcons = cfg.enableIcons; };
      bookmarks = {
        d = "~/Documents";
        D = "~/Downloads";
        p = "~/Pictures";
        v = "~/Videos";
        m = "/mnt";
        "/" = "/";
      };
      extraPackages = with pkgs; [
        bat
        eza
        fzf
        mediainfo
      ] ++ lib.optionals (!stdenv.isDarwin) [
        ffmpegthumbnailer
        sxiv
      ];
      plugins = {
        src = "${inputs.nnn-plugins}/plugins";
        mappings = {
          c = "fzcd";
          f = "finder";
          o = "fzopen";
          p = "preview-tui";
          t = "nmount";
          v = "imgview";
        };
      };
    };

    programs.zsh.initExtra = ''
      n()
      {
        # Block nesting of nnn in subshells
        if [ -n $NNNLVL ] && [ "''${NNNLVL:-0}" -ge 1 ]; then
          echo "nnn is already running"
          return
        fi

        # The default behaviour is to cd on quit (nnn checks if NNN_TMPFILE is set)
        # To cd on quit only on ^G, remove the "export" as in:
        #     NNN_TMPFILE="''${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
        # NOTE: NNN_TMPFILE is fixed, should not be modified
        export NNN_TMPFILE="''${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

        # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
        # stty start undef
        # stty stop undef
        # stty lwrap undef
        # stty lnext undef

        ${config.programs.nnn.finalPackage}/bin/nnn -a "$@"

        if [ -f "$NNN_TMPFILE" ]; then
          . "$NNN_TMPFILE"
          rm -f "$NNN_TMPFILE" > /dev/null
        fi
      }
    '';
  };
}

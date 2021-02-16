{ config, lib, pkgs, inputs, ... }:

{
  home = {
    packages = with pkgs; [ bat exa ffmpegthumbnailer mediainfo nnn sxiv ];
    sessionVariables = {
      NNN_PLUG = "c:fzcd;f:finder;o:fzopen;p:preview-tui;t:nmount;v:imgview";
      NNN_BMS = "D:~/Downloads/;I:~/Pictures;V:~/Videos;P:~/Projects;m:/mnt;r:/";
      USE_VIDEOTHUMB = 1;
    };
  };

  xdg.configFile."nnn/plugins" = {
    source = pkgs.nnnPlugins;
    recursive = true;
  };

  programs.zsh.initExtra = let nnn = "${pkgs.nnn}/bin/nnn";
  in ''
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

      ${nnn} -a "$@"

      if [ -f "$NNN_TMPFILE" ]; then
        . "$NNN_TMPFILE"
        rm -f "$NNN_TMPFILE" > /dev/null
      fi
    }
  '';
}

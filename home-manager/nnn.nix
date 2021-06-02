{ config, lib, pkgs, inputs, ... }:

# TODO: Convert this to a module
{
  nixpkgs.overlays = [
    (final: prev: rec {
      nnnWithIcons = pkgs.nnn.override ({ withNerdIcons = true; });

      nnnCustom = pkgs.writeShellScriptBin "nnn" ''
        export NNN_PLUG="c:fzcd;f:finder;o:fzopen;p:preview-tui;t:nmount;v:imgview";
        export NNN_BMS="D:~/Downloads/;I:~/Pictures;V:~/Videos;P:~/Projects;m:/mnt;r:/";
        export USE_VIDEOTHUMB=1;

        ${pkgs.nnnWithIcons}/bin/nnn -a "$@"
      '';

      nnnPlugins = with pkgs;
        let inherit (nnn) version;
        in
        stdenv.mkDerivation rec {
          name = "nnn-plugins-${version}";
          src = fetchFromGitHub {
            owner = "jarun";
            repo = "nnn";
            rev = "v${version}";
            sha256 = "sha256-Hpc8YaJeAzJoEi7aJ6DntH2VLkoR6ToP6tPYn3llR7k=";
          };
          buildPhase = "true";
          installPhase = ''
            mkdir -p $out
            cp -rT plugins $out
          '';
        };
    })
  ];

  home = {
    packages = with pkgs; [
      bat
      exa
      ffmpegthumbnailer
      mediainfo
      nnnCustom
      sxiv
    ];
  };

  xdg.configFile."nnn/plugins" = {
    source = pkgs.nnnPlugins;
    recursive = true;
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

      ${pkgs.nnnCustom}/bin/nnn -a "$@"

      if [ -f "$NNN_TMPFILE" ]; then
        . "$NNN_TMPFILE"
        rm -f "$NNN_TMPFILE" > /dev/null
      fi
    }
  '';
}

{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.home-manager.cli.zsh;
  get-ip = pkgs.writeShellApplication {
    name = "get-ip";
    runtimeInputs = with pkgs; [ curl ];
    text = "curl -Ss --fail https://ipapi.co/yaml";
  };
  realise-symlink = pkgs.writeShellApplication {
    name = "realise-symlink";
    runtimeInputs = with pkgs; [ coreutils ];
    text = ''
      for file in "$@"; do
        if [[ -L "$file" ]]; then
          if [[ -d "$file" ]]; then
            tmpdir="''${file}.tmp"
            mkdir -p "$tmpdir"
            cp --verbose --recursive "$file"/* "$tmpdir"
            unlink "$file"
            mv "$tmpdir" "$file"
            chmod --changes --recursive +w "$file"
          else
            cp --verbose --remove-destination "$(readlink "$file")" "$file"
            chmod --changes +w "$file"
          fi
        else
          >&2 echo "Not a symlink: $file"
          exit 1
        fi
      done
    '';
  };
in
{
  options.home-manager.cli.zsh = {
    enable = lib.mkEnableOption "ZSH config" // {
      default = config.home-manager.cli.enable;
    };
    zprof.enable = lib.mkEnableOption "zsh/zprof module";
  };

  config = lib.mkIf cfg.enable {
    home = {
      # disable login banner
      file.".hushlogin".text = "";
      packages =
        with pkgs;
        [
          get-ip
          realise-symlink
        ]
        ++ lib.optionals (!config.home-manager.darwin.enable) [
          (run-bg-alias "open" (lib.getExe' xdg-utils "xdg-open"))
        ];

      sessionPath = [ "$HOME/.local/bin" ];
      sessionSearchVariables.MANPATH = lib.mkAfter [ ":" ];
    };

    programs = {
      dircolors.enable = true;
      fzf = {
        enable = true;
        fileWidgetOptions = [ "--preview 'head {}'" ];
        historyWidgetOptions = [ "--sort" ];
      };
      zoxide.enable = true;
      zsh = {
        enable = true;
        autocd = true;
        defaultKeymap = "viins";

        history = {
          append = true;
          expireDuplicatesFirst = true;
          extended = true;
          ignoreDups = true;
          ignoreSpace = true;
          share = true;
        };

        envExtra = lib.mkBefore (
          lib.optionalString config.home-manager.darwin.enable
            # bash
            ''
              # Source nix-daemon profile since macOS updates can remove it from /etc/zshrc
              # https://github.com/NixOS/nix/issues/3616
              if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
                . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
              fi
            ''
        );

        initContent = lib.mkMerge [
          # Enable zprof but don't print its output
          # We can still call it by calling zprof manually
          (lib.mkIf cfg.zprof.enable (
            lib.mkOrder 400
              # bash
              ''
                zmodload zsh/zprof
              ''
          ))
          (lib.mkOrder 1000
            # bash
            ''
              # fix "no matches found" when using glob characters
              setopt no_nomatch
              # disable clock
              unset RPROMPT

              # prezto default matching does annoying partial matching
              # e.g.: something-|.json
              zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' 'm:{[:upper:]}={[:lower:]}' 'r:|=* r:|=*'

              # map V in vi-mode to edit the current command line in $VISUAL
              export VISUAL="$EDITOR"
              bindkey -M vicmd 'V' edit-command-line
              bindkey -M viins 'V' edit-command-line
            ''
          )
          (lib.mkOrder 1200 (
            lib.optionalString config.home-manager.darwin.enable # bash
              ''
                # Set the soft ulimit to something sensible
                # https://developer.apple.com/forums/thread/735798
                ulimit -Sn 524288
              ''
          ))
          (lib.mkOrder 1300
            # bash
            ''
              # source contents from ~/.zshrc.d/*.zsh
              for file in "$HOME/.zshrc.d/"*.zsh(N); do
                [[ -f "$file" ]] && source "$file"
              done
            ''
          )
          (lib.mkOrder 1400
            # bash
            ''
              # defer loading until prompt is ready
              autoload -Uz add-zsh-hook
              add-zsh-hook -d precmd _history-substring-search-end 2>/dev/null
              add-zsh-hook precmd () {
                pmodload 'history-substring-search'
                # rebind the widgets
                zle -N history-substring-search-up
                zle -N history-substring-search-down
              }
            ''
          )
        ];

        prezto = {
          enable = true;
          prompt.theme = "pure";
          editor.keymap = "vi";
          pmodules = [
            "environment"
            "terminal"
            "editor"
            "directory"
            "spectrum"
            "utility"
            "completion"
            "prompt"
            "autosuggestions"
          ];
        };

        plugins = with pkgs; [
          # manually creating some integrations since this is faster than calling
          # the program during startup
          {
            name = "nix-your-shell";
            src = pkgs.runCommand "nix-your-shell" { buildInputs = [ pkgs.nix-your-shell ]; } ''
              mkdir -p $out
              nix-your-shell --absolute zsh > $out/nix-your-shell.plugin.zsh
            '';
          }
          {
            name = "zsh-fast-syntax-highlighting";
            file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
            src = zsh-fast-syntax-highlighting;
          }
          {
            name = "zsh-autopair";
            file = "share/zsh/zsh-autopair/autopair.zsh";
            src = zsh-autopair;
          }
        ];

        sessionVariables = {
          PAGER = "less";
          LESS = lib.concatStringsSep " " [
            "--hilite-search"
            "--ignore-case"
            "--long-prompt"
            "--raw-control-chars"
            "--chop-long-lines"
            "--hilite-unread"
            "--window=4"
          ];
          # Reduce time to wait for multi-key sequences
          KEYTIMEOUT = 1;
          # Set right prompt to show time
          RPROMPT = "%F{8}%*";
        };

        shellAliases = {
          # https://unix.stackexchange.com/questions/335648/why-does-the-reset-command-include-a-delay
          reset = "${lib.getExe' pkgs.ncurses "tput"} reset";
        };
      };
    };
  };
}

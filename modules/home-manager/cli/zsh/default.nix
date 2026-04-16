{
  config,
  pkgs,
  lib,
  flake,
  ...
}:

let
  inherit (config.programs.zsh) dotDir;
  cfg = config.home-manager.cli.zsh;
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
      file =
        let
          libZsh = import (flake.inputs.home-manager + "/modules/programs/zsh/lib.nix") {
            inherit config lib;
          };
          compileZshConfig =
            filename:
            pkgs.runCommand filename
              {
                name = "${filename}-zwc";
                nativeBuildInputs = [ pkgs.zsh ];
              }
              ''
                cp "${config.home.file.${libZsh.dotDirRel + "/" + filename}.source}" "${filename}"
                zsh -c 'zcompile "${filename}"'
                cp "${filename}.zwc" "$out"
              '';
        in
        {
          # disable login banner
          ".hushlogin".text = "";
          ".zprofile.zwc".source = compileZshConfig ".zprofile";
          ".zshenv.zwc".source = compileZshConfig ".zshenv";
          ".zshrc.zwc".source = compileZshConfig ".zshrc";
        };

      packages =
        with pkgs;
        [ realise-symlink ]
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
        autosuggestion.enable = true;
        defaultKeymap = "viins";
        dotDir = config.home.homeDirectory;
        enableCompletion = true;
        enableVteIntegration = true;
        history = {
          append = true;
          expireDuplicatesFirst = true;
          extended = true;
          ignoreDups = true;
          ignoreSpace = true;
          share = true;
        };
        historySubstringSearch = {
          enable = true;
        };

        completionInit = # bash
          ''
            # Load and initialize the completion system ignoring insecure directories with a
            # cache time of 20 hours, so it should almost always regenerate the first time a
            # shell is opened each day.
            autoload -Uz compinit
            _comp_path="${dotDir}/.zcompdump"
            # #q expands globs in conditional expressions
            if [[ $_comp_path(#qNmh-20) ]]; then
              # -C (skip function check) implies -i (skip security check).
              compinit -C -d "$_comp_path"
            else
              mkdir -p "$_comp_path:h"
              compinit -i -d "$_comp_path"
              # Keep $_comp_path younger than cache time even if it isn't regenerated.
              touch "$_comp_path"
            fi
            unset _comp_path
          '';

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
              setopt NO_NOMATCH           # Fix "no matches found" when using glob characters
              setopt ALWAYS_TO_END        # Move cursor to the end of a completed word.
              setopt PATH_DIRS            # Perform path search even on command names with slashes.
              setopt AUTO_MENU            # Show completion menu on a successive tab press.
              setopt AUTO_LIST            # Automatically list choices on ambiguous completion.
              setopt AUTO_PARAM_SLASH     # If completed parameter is a directory, add a trailing slash.
              setopt EXTENDED_GLOB        # Needed for file modification glob modifiers with compinit.
              unsetopt COMPLETE_IN_WORD   # Do not complete from both ends of a word.
              unsetopt MENU_COMPLETE      # Do not autoselect the first completion entry.
              unsetopt FLOW_CONTROL       # Disable start/stop characters in shell editor.

              # Map V in vi-mode to edit the current command line in $VISUAL
              bindkey -M vicmd 'V' edit-command-line

              # Pure related options
              unset RPROMPT # disable clock
              zstyle ':prompt:pure:prompt:success' color 39 # miku color

              # Defaults.
              zstyle ':completion:*:default' list-colors ''${(s.:.)LS_COLORS}
              zstyle ':completion:*:default' list-prompt '%S%M matches%s'

              # Use caching to make completion for commands usable.
              zstyle ':completion::complete:*' use-cache on
              zstyle ':completion::complete:*' cache-path "${dotDir}/.zcompdump"
            ''
          )
          (lib.mkOrder 1200 (
            lib.optionalString config.home-manager.darwin.enable # bash
              ''
                # This is really slow on darwin
                export PURE_GIT_UNTRACKED_DIRTY=0
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
        ];

        profileExtra = # bash
          ''
            # Ensure path arrays do not contain duplicates.
            typeset -gU cdpath fpath mailpath path
          '';

        plugins =
          let
            compileZshPlugin =
              plugin:
              plugin
              // {
                src =
                  pkgs.runCommand "${plugin.name}-zwc"
                    {
                      nativeBuildInputs = [ pkgs.zsh ];
                    }
                    ''
                      cp -rT ${plugin.src} "$out"
                      chmod -R u+w "$out"
                      cd "$out"

                      find . -type f -name '*.zsh' | while IFS= read -r file; do
                        zsh -fc "zcompile \"$file\""
                      done
                    '';
              };
          in
          map compileZshPlugin (
            with pkgs;
            [
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
                file = "share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh";
                src = zsh-fast-syntax-highlighting;
              }
              {
                name = "zsh-autopair";
                file = "share/zsh/zsh-autopair/autopair.zsh";
                src = zsh-autopair;
              }
              {
                name = "pure-prompt";
                file = "share/zsh/site-functions/prompt_pure_setup";
                completions = [ "share/zsh/site-functions" ];
                src = pure-prompt;
              }
            ]
          );

        sessionVariables = {
          # Reduce time to wait for multi-key sequences
          KEYTIMEOUT = 1;
          # Set right prompt to show time
          RPROMPT = "%F{8}%*";
        };

        shellAliases = {
          # https://unix.stackexchange.com/questions/335648/why-does-the-reset-command-include-a-delay
          reset = "${lib.getExe' pkgs.ncurses "tput"} reset";
          ls = "${lib.getExe' pkgs.coreutils "ls"} --color=auto";
          ll = "${lib.getExe' pkgs.coreutils "ls"} -l --color=auto";
        };
      };
    };
  };
}

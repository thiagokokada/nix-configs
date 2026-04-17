{
  config,
  pkgs,
  lib,
  flake,
  ...
}:

let
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
      file = {
        # disable login banner
        ".hushlogin".text = "";
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
      dircolors = {
        enable = true;
        enableZshIntegration = false;
      };
      fzf = {
        enable = true;
        fileWidgetOptions = [ "--preview 'head {}'" ];
        historyWidgetOptions = [ "--sort" ];
      };
      zoxide = {
        enable = true;
        enableZshIntegration = false;
      };
      zsh = {
        enable = true;

        autocd = true;
        autosuggestion = {
          enable = true;
          strategy = [
            "history"
            "completion"
          ];
        };
        completionInit =
          # bash
          ''
            # Fast startup: use existing dump immediately.
            autoload -Uz compinit
            compinit -C -d "''${ZDOTDIR:-$HOME}/.zcompdump"

            (
              emulate -L zsh -o extended_glob

              local zdumpfile lockfile
              local -a zcomps zmtimes
              local LC_ALL=C
              local zold_dat
              local -i zdump_dat=1

              zstyle -s ':zim:completion' dumpfile zdumpfile || zdumpfile="''${ZDOTDIR:-$HOME}/.zcompdump"
              lockfile="''${zdumpfile}.lock"

              zmodload -F zsh/system b:zsystem || return 0
              : >| "$lockfile" || return 0

              # Do not wait. If another refresh is already running, just exit.
              zsystem flock -t 0 -f lockfd "$lockfile" || return 0

              zcomps=(''${^fpath}/^([^_]*|*~|*.zwc)(N))
              if (( ''${#zcomps} )); then
                zmodload -F zsh/stat b:zstat || return 0
                zstat -A zmtimes +mtime -- ''${zcomps} || return 0
              fi

              local -r znew_dat="$ZSH_VERSION"$'\0'"''${(pj:\0:)zcomps}"$'\0'"''${(pj:\0:)zmtimes}"

              if [[ -e ''${zdumpfile}.dat ]]; then
                zmodload -F zsh/system b:sysread || return 0
                sysread -s $(( ''${#znew_dat} )) zold_dat < "''${zdumpfile}.dat" || true
                if [[ "$zold_dat" == "$znew_dat" && -e ''${zdumpfile}.zwc ]]; then
                  zdump_dat=0
                fi
              fi

              (( zdump_dat )) || return 0

              command rm -f -- "''${zdumpfile}"{,.dat,.zwc,.zwc.old,.old} 2>/dev/null || true
              autoload -Uz compinit || return 0
              compinit -C -d "$zdumpfile" || return 0
              print -rn -- "$znew_dat" >| "''${zdumpfile}.dat" || return 0
              zcompile "$zdumpfile" 2>/dev/null || true
            ) >/dev/null 2>&1 &!
          '';
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
          size = 10000;
          save = 20000;
        };
        # Reduce time to wait for multi-key sequences
        localVariables.KEYTIMEOUT = 1;
        historySubstringSearch.enable = true;
        setOptions = [
          # Fix "no matches found" when using glob characters
          "NO_NOMATCH"
          # Move cursor to the end of a completed word.
          "ALWAYS_TO_END"
          # Perform path search even on command names with slashes.
          "PATH_DIRS"
          # Show completion menu on a successive tab press.
          "AUTO_MENU"
          # Automatically list choices on ambiguous completion.
          "AUTO_LIST"
          # If completed parameter is a directory, add a trailing slash.
          "AUTO_PARAM_SLASH"
          # Treat `#`, `~`, and `^` as patterns for filename globbing.
          "EXTENDED_GLOB"
          # Case insenstive glob
          "NO_CASE_GLOB"
          # Do not complete from both ends of a word.
          "NO_COMPLETE_IN_WORD"
          # Do not autoselect the first completion entry.
          "NO_MENU_COMPLETE"
          # Disable start/stop characters in shell editor.
          "NO_FLOW_CONTROL"
          # Make cd push the old directory to the directory stack.
          "AUTO_PUSHD"
          # Don't push multiple copies of the same directory to the stack.
          "PUSHD_IGNORE_DUPS"
          # Don't print the directory stack after pushd or popd.
          "PUSHD_SILENT"
          # Allow comments starting with `#` in the interactive shell.
          "INTERACTIVE_COMMENTS"
          # Completion is done from both ends of the cursor.
          "COMPLETE_IN_WORD"
          # Don't beep on ambiguous completions.
          "NO_LIST_BEEP"
        ];

        envExtra = lib.mkBefore (
          lib.optionalString config.home-manager.darwin.enable
            # bash
            ''
              # Source nix-daemon profile since macOS updates can remove it from /etc/zshrc
              # https://github.com/NixOS/nix/issues/3616
              if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
                . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
              fi

              # Set the soft ulimit to something sensible
              # https://developer.apple.com/forums/thread/735798
              ulimit -Sn 524288
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
              # Map V in vi-mode to edit the current command line in $VISUAL
              bindkey -M vicmd 'V' edit-command-line

              # Pure related options
              unset RPROMPT # disable clock
              zstyle :prompt:pure:prompt:success color 39 # miku color
              zstyle :prompt:pure:git:fetch only_upstream yes
            ''
          )
          (lib.mkOrder 1200
            # Inspired by zim-completion
            # https://github.com/zimfw/completion/blob/8d3e0f4e6272f4d3bad659eaa13929f9dd96f123/init.zsh
            # bash
            ''
              # Enable caching
              zstyle ':completion::complete:*' use-cache on

              # Group matches and describe.
              zstyle ':completion:*' menu select
              zstyle ':completion:*:matches' group yes
              zstyle ':completion:*:options' description yes
              zstyle ':completion:*:options' auto-description '%d'
              zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'
              zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
              zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
              zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
              zstyle ':completion:*' group-name ""
              zstyle ':completion:*' verbose yes
              # This is actually "smart" case sensitivity. Case insensitive is 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}'
              # which is broken in Zsh 5.9. See https://www.zsh.org/mla/workers/2022/msg01229.html
              zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]}' '+r:|[._-]=* r:|=*' '+l:|=*'

              # Insert a TAB character instead of performing completion when left buffer is empty.
              zstyle ':completion:*' insert-tab false

              # Ignore useless commands and functions
              zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec)|prompt_*)'
              # Array completion element sorting.
              zstyle ':completion:*:*:-subscript-:*' tag-order 'indexes' 'parameters'

              # Directories
              zstyle ':completion:*:default' list-colors ''${(s.:.)LS_COLORS}
              zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
              zstyle ':completion:*' squeeze-slashes true

              # History
              zstyle ':completion:*:history-words' stop yes
              zstyle ':completion:*:history-words' remove-all-dups yes
              zstyle ':completion:*:history-words' list false
              zstyle ':completion:*:history-words' menu yes

              # Populate hostname completion.
              zstyle -e ':completion:*:hosts' hosts 'reply=(
                ''${=''${=''${=''${''${(f)"$(cat {/etc/ssh/ssh_,~/.ssh/}known_hosts{,2} 2>/dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
                ''${=''${(f)"$(cat /etc/hosts 2>/dev/null; (( ''${+commands[ypcat]} )) && ypcat hosts 2>/dev/null)"}%%(\#)*}
                ''${=''${''${''${''${(@M)''${(f)"$(cat ~/.ssh/config{,.d/*(N)} 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
              )'

              # Don't complete uninteresting users...
              zstyle ':completion:*:*:*:users' ignored-patterns \
                '_*' adm amanda apache avahi beaglidx bin cacti canna clamav daemon dbus \
                distcache dovecot fax ftp games gdm gkrellmd gopher hacluster haldaemon \
                halt hsqldb ident junkbust ldap lp mail mailman mailnull mldonkey mysql \
                nagios named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
                operator pcap postfix postgres privoxy pulse pvm quagga radvd rpc rpcuser \
                rpm shutdown squid sshd sync uucp vcsa xfs

              # ... unless we really want to.
              zstyle ':completion:*' single-ignored show

              # Ignore multiple entries.
              zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
              zstyle ':completion:*:rm:*' file-patterns '*:all-files'

              # Man
              zstyle ':completion:*:manuals' separate-sections true
              zstyle ':completion:*:manuals.(^1*)' insert-sections true
            ''
          )
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

        plugins = with pkgs; [
          {
            name = "zim-input";
            src = flake.inputs.zim-input;
            file = "init.zsh";
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
          # manually creating some integrations since this is faster than calling
          # the program during startup
          {
            name = "dircolors";
            src = pkgs.runCommand "nix-your-shell-zsh" { buildInputs = [ pkgs.coreutils ]; } ''
              mkdir -p $out
              dircolors -b ${config.home.file.".dir_colors".source} > $out/dircolors.plugin.zsh
            '';
          }
          {
            name = "nix-your-shell";
            src = pkgs.runCommand "nix-your-shell-zsh" { buildInputs = [ pkgs.nix-your-shell ]; } ''
              mkdir -p $out
              nix-your-shell --absolute zsh > $out/nix-your-shell.plugin.zsh
            '';
          }
          {
            name = "zoxide";
            src = pkgs.runCommand "zoxide-zsh" { buildInputs = [ pkgs.zoxide ]; } ''
              mkdir -p $out
              zoxide init zsh > $out/zoxide.plugin.zsh
            '';
          }
        ];

        shellAliases = {
          # https://unix.stackexchange.com/questions/335648/why-does-the-reset-command-include-a-delay
          reset = "${lib.getExe' pkgs.ncurses "tput"} reset";
          l = "${lib.getExe' pkgs.coreutils "ls"} -alh --color=auto";
          ls = "${lib.getExe' pkgs.coreutils "ls"} --color=auto";
          ll = "${lib.getExe' pkgs.coreutils "ls"} -l --color=auto";
        };
      };
    };
  };
}

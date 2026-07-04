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
        [
          nix-your-shell
          realise-symlink
        ]
        ++ lib.optionals (!config.home-manager.darwin.enable) [
          (run-bg-alias "open" (lib.getExe' xdg-utils "xdg-open"))
        ];
    };

    programs = {
      dircolors = {
        enable = true;
        enableZshIntegration = false;
      };
      fzf = {
        enable = true;
        fileWidget.options = [ "--preview 'head {}'" ];
        historyWidget.options = [ "--sort" ];
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
        completionInit = ""; # set by zim-completion
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
        historySubstringSearch = {
          enable = true;
          searchUpKey = [ "$terminfo[kcud1]" ];
          searchDownKey = [ "$terminfo[kcuu1]" ];
        };
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

              # Realias zsh-z to use fzf
              unalias z
              z() {
                [ $# -gt 0 ] && zshz "$*" && return
                cd "$(zshz -l 2>&1 | fzf --height 40% --nth 2.. --reverse --inline-info +s --tac --query "''${*##-* }" | sed 's/^[0-9,.]* *//')"
              }
            ''
          )
          # history-substring-search module order is 1250
          # https://github.com/nix-community/home-manager/blob/7f8bbc93d63401e41368d6ddc46a4f631610fa90/modules/programs/zsh/history.nix#L227
          (lib.mkOrder 1300
            # bash
            ''
              # Keep substring search consistent in both insert and command mode.
              ${lib.concatMapStringsSep "\n" (
                upKey: ''bindkey -M viins "${upKey}" history-substring-search-up''
              ) (lib.toList config.programs.zsh.historySubstringSearch.searchUpKey)}
              ${lib.concatMapStringsSep "\n" (
                downKey: ''bindkey -M viins "${downKey}" history-substring-search-down''
              ) (lib.toList config.programs.zsh.historySubstringSearch.searchDownKey)}
              bindkey -M vicmd "k" history-substring-search-up
              bindkey -M vicmd "j" history-substring-search-down
            ''
          )
          (lib.mkOrder 1400
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
            name = "zim-completion";
            src = flake.inputs.zim-completion;
            file = "init.zsh";
          }
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
            functions = [ "share/zsh/site-functions" ];
            src = pure-prompt;
          }
          # manually creating some integrations since this is faster than calling
          # the program during startup
          {
            name = "dircolors";
            src = pkgs.runCommand "dircolors-zsh" { buildInputs = [ pkgs.coreutils ]; } ''
              mkdir -p $out
              dircolors -b ${config.home.file.".dir_colors".source} > $out/dircolors.plugin.zsh
            '';
          }
          {
            name = "nix-your-shell";
            src = pkgs.runCommand "nix-your-shell-zsh" { buildInputs = [ pkgs.nix-your-shell ]; } ''
              mkdir -p $out
              nix-your-shell zsh > $out/nix-your-shell.plugin.zsh
            '';
          }
          {
            name = "zsh-z";
            file = "share/zsh-z/zsh-z.plugin.zsh";
            src = zsh-z;
          }
        ];

        shellAliases = {
          reset = lib.getExe' pkgs.ncurses "reset";
          l = "${lib.getExe' pkgs.coreutils "ls"} -alh --color=auto";
          ls = "${lib.getExe' pkgs.coreutils "ls"} --color=auto";
          ll = "${lib.getExe' pkgs.coreutils "ls"} -l --color=auto";
        };
      };
    };
  };
}

{ ... }:

{
  programs.zsh = {
    enable = true;
    autocd = true;
    defaultKeymap = "viins";
    enableCompletion = true;
    enableAutosuggestions = true;

    history = {
      ignoreDups = true;
      ignoreSpace = true;
      expireDuplicatesFirst = true;
      share = true;
    };

    sessionVariables = {
      # Reduce time to wait for multi-key sequences
      KEYTIMEOUT = 1;
      # Set right prompt to show time
      RPROMPT = "%F{8}%*";
      # zsh-users config
      ZSH_AUTOSUGGEST_USE_ASYNC = 1;
      ZSH_HIGHLIGHT_HIGHLIGHTERS = [ "main" "brackets" "cursor" ];
    };

    shellAliases = {
      "reload!" = "source $HOME/.zshrc";
      dotfiles = "cd $DOTFILES_PATH";
      dotfiles-pull = "git -C $DOTFILES_PATH pull";
    };

    initExtraBeforeCompInit = ''
      # zimfw config
      zstyle ':zim:input' double-dot-expand yes
      zstyle ':zim:ssh' ids /dev/null
    '';

    initExtra = ''
      # helpers
      close-fd() { "$@" </dev/null &>/dev/null }
      run-bg() { "$@" </dev/null &>/dev/null &! }
      open() { run-bg xdg-open "$@" }
      restart() { pkill "$1"; run-bg "$@" }
      get-ip() { curl -Ss "https://ifconfig.me" }
      get-ip!() { curl -Ss "https://ipapi.co/$(get-ip)/yaml" }

      # try to correct the spelling of commands
      setopt correct
      # Disable C-S/C-Q
      setopt noflowcontrol

      # Edit in vim
      autoload -U edit-command-line
      zle -N edit-command-line
      bindkey -M vicmd v edit-command-line

      # zsh-history-substring-search
      bindkey "$terminfo[kcuu1]" history-substring-search-up
      bindkey "$terminfo[kcud1]" history-substring-search-down

      # source contents from ~/.zshrc.d/*.zsh
      for file in $HOME/.zshrc.d/*.zsh; do
        [[ -f "$file" ]] && source "$file"
      done

      # load after ~/.zshrc.d files to make sure that ~/.local/bin is the first in $PATH
      export PATH="$HOME/.local/bin:$PATH"
    '';

    # TODO: Create script to update those plugins
    plugins = [
      # TODO: Remove after migration
      {
        name = "zit";
        src = fetchGit {
          url = "https://github.com/thiagokokada/zit";
          ref = "master";
          rev = "15a02d6b0dc22b4d4e70cfec9242dee8501404ff";
        };
        file = "zit.zsh";
      }
      {
        name = "zim-completion";
        src = fetchGit {
          url = "https://github.com/zimfw/completion";
          ref = "master";
          rev = "db9c17717864e424e3e0e2f69afa4b83db78b559";
        };
        file = "init.zsh";
      }
      {
        name = "zim-environment";
        src = fetchGit {
          url = "https://github.com/zimfw/environment";
          ref = "master";
          rev = "016d897e909eca6efc6f8bb95b4b952e0b4a5424";
        };
        file = "init.zsh";
      }
      {
        name = "zim-input";
        src = fetchGit {
          url = "https://github.com/zimfw/input";
          ref = "master";
          rev = "2f95e2aeed9b4cc3e383adcb41c7a9e8d9f8d89d";
        };
        file = "init.zsh";
      }
      {
        name = "zim-git";
        src = fetchGit {
          url = "https://github.com/zimfw/git";
          ref = "master";
          rev = "2f29e24ba27da901770e8008ace9f18292fddd6e";
        };
        file = "init.zsh";
      }
      {
        name = "zim-ssh";
        src = fetchGit {
          url = "https://github.com/zimfw/ssh";
          ref = "master";
          rev = "f4182fa0a790e59ffe02beaa96e5ac3a36c72f26";
        };
        file = "init.zsh";
      }
      {
        name = "zim-utility";
        src = fetchGit {
          url = "https://github.com/zimfw/utility";
          ref = "master";
          rev = "5fc2348ff5688972cdc87a2010796525e9656966";
        };
        file = "init.zsh";
      }
      {
        name = "pure";
        src = fetchGit {
          url = "https://github.com/sindresorhus/pure";
          ref = "main";
          rev = "b83ad6dcb0726feec1cce550d84fc710e2ef7912";
        };
      }
      {
        name = "autopair";
        src = fetchGit {
          url = "https://github.com/hlissner/zsh-autopair";
          ref = "master";
          rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
        };
      }
      {
        name = "zsh-completions";
        src = fetchGit {
          url = "https://github.com/zsh-users/zsh-completions";
          ref = "master";
          rev = "6fe9995fd953d042bb3704610f421b270ceb2319";
        };
      }
      {
        name = "zsh-syntax-highlighting";
        src = fetchGit {
          url = "https://github.com/zsh-users/zsh-syntax-highlighting";
          ref = "master";
          rev = "5eb494852ebb99cf5c2c2bffee6b74e6f1bf38d0";
        };
      }
      {
        name = "zsh-history-substring-search";
        src = fetchGit {
          url = "https://github.com/zsh-users/zsh-history-substring-search";
          ref = "master";
          rev = "0f80b8eb3368b46e5e573c1d91ae69eb095db3fb";
        };
      }
    ];
  };

  programs.autojump.enable = true;
  programs.dircolors.enable = true;
  programs.fzf = {
    enable = true;
    fileWidgetOptions = [ "--preview 'head {}'" ];
    historyWidgetOptions = [ "--sort" ];
  };
}

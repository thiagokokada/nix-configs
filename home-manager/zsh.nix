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
      PATH = "$HOME/.local/bin:$PATH";
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
    '';

    plugins = import ./zsh-plugins.nix { inherit fetchGit; };
  };

  programs.autojump.enable = true;
  programs.dircolors.enable = true;
  programs.fzf = {
    enable = true;
    fileWidgetOptions = [ "--preview 'head {}'" ];
    historyWidgetOptions = [ "--sort" ];
  };
}

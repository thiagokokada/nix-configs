{ config, pkgs, lib, flake, ... }:
{
  home.packages = with pkgs; lib.optionals (!stdenv.isDarwin) [
    (run-bg-alias "open" "${xdg-utils}/bin/xdg-open")
  ];

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
      # Enable scroll support
      LESS = "--RAW-CONTROL-CHARS";
      # Reduce time to wait for multi-key sequences
      KEYTIMEOUT = 1;
      # Set right prompt to show time
      RPROMPT = "%F{8}%*";
      # zsh-users config
      ZSH_AUTOSUGGEST_USE_ASYNC = 1;
      ZSH_HIGHLIGHT_HIGHLIGHTERS = [ "main" "brackets" "cursor" ];
    };

    shellAliases = { "reload!" = "source $HOME/.zshrc"; };

    profileExtra =
      let
        darwinFixes = lib.optionalString pkgs.stdenv.isDarwin ''
          # Source nix-daemon profile since macOS updates can remove it from /etc/zshrc
          # https://github.com/NixOS/nix/issues/3616
          if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
            source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
          fi
        '';
      in
      ''
        # Source .profile
        [[ -e ~/.profile ]] && emulate sh -c '. ~/.profile'
        ${darwinFixes}
      '';

    initExtraBeforeCompInit = ''
      # zimfw config
      zstyle ':zim:input' double-dot-expand yes
      zstyle ':zim:ssh' ids /dev/null
    '';

    initExtra = with pkgs; ''
      # helpers
      run-bg() {
        (
          exec 0>&-
          exec 1>&-
          exec 2>&-
          "$@"
        ) &!
      }
      get-ip() { ${curl}/bin/curl -Ss "https://ifconfig.me" }
      get-ip!() { ${curl}/bin/curl -Ss "https://ipapi.co/$(get-ip)/yaml" }
      remove-symlink() {
        [[ -L "$1" ]] && cp --remove-destination "$(readlink "$1")" "$1"
      }

      # allow using nix-shell with zsh
      ${any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin

      # try to correct the spelling of commands
      setopt correct
      # disable C-S/C-Q
      setopt noflowcontrol
      # disable "no matches found" check
      unsetopt nomatch

      # zsh-history-substring-search
      bindkey "$terminfo[kcuu1]" history-substring-search-up
      bindkey "$terminfo[kcud1]" history-substring-search-down

      # allow ad-hoc scripts to be add to PATH locally
      export PATH="$HOME/.local/bin:$PATH"

      # source contents from ~/.zshrc.d/*.zsh
      for file in "$HOME/.zshrc.d/"*.zsh; do
        [[ -f "$file" ]] && source "$file"
      done

      # avoid duplicated entries in PATH
      typeset -U PATH

      # ensure that MANPATH includes a :
      # https://askubuntu.com/a/693612
      export MANPATH=":$MANPATH"
    '';

    plugins =
      let
        zshCompilePlugin = name: src:
          pkgs.runCommand name
            {
              name = "${name}-zwc";
              nativeBuildInputs = [ pkgs.zsh ];
            } ''
            mkdir $out
            cp -rT ${src} $out
            cd $out
            find -name '*.zsh' -execdir zsh -c 'zcompile {}' \;
          '';
        zshPlugin = name:
          {
            inherit name;
            src = zshCompilePlugin name (builtins.getAttr name flake.inputs);
          };
        zimPlugin = name:
          zshPlugin name // { file = "init.zsh"; };
      in
      lib.flatten [
        (zimPlugin "zim-completion")
        (zimPlugin "zim-input")
        (zimPlugin "zim-git")
        (zimPlugin "zim-ssh")
        (zimPlugin "zim-utility")
        (zshPlugin "pure")
        (zshPlugin "zsh-autopair")
        (zshPlugin "zsh-completions")
        (zshPlugin "zsh-syntax-highlighting")
        # Should be the last one
        (zshPlugin "zsh-history-substring-search")
      ];
  };

  home.file =
    let
      compileZshConfig = filename:
        pkgs.runCommand filename
          {
            name = "${filename}-zwc";
            nativeBuildInputs = [ pkgs.zsh ];
          } ''
          cp "${config.home.file.${filename}.source}" "${filename}"
          zsh -c 'zcompile "${filename}"'
          cp "${filename}.zwc" "$out"
        '';
    in
    {
      ".zprofile.zwc".source = compileZshConfig ".zprofile";
      ".zshenv.zwc".source = compileZshConfig ".zshenv";
      ".zshrc.zwc".source = compileZshConfig ".zshrc";
    };

  programs = {
    dircolors.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fzf = {
      enable = true;
      fileWidgetOptions = [ "--preview 'head {}'" ];
      historyWidgetOptions = [ "--sort" ];
    };
    zoxide.enable = true;
  };
}

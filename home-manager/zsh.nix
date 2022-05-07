{ config, pkgs, lib, self, ... }:
let
  # Based on https://github.com/zimfw/archive
  archive = pkgs.writeScriptBin "archive" ''
    #!${pkgs.zsh}/bin/zsh

    readonly name="$(${pkgs.coreutils}/bin/basename "$0")"

    if (( # < 2 )); then
      print -u2 "usage: $name <archive_name.ext> <file>..."
      return 2
    fi

    case "$1" in
      (*.7z) ${pkgs.p7zip}/bin/7za a "$@" ;;
      (*.rar) ${pkgs.rar}/bin/rar a "$@" ;;
      (*.tar.bz|*.tar.bz2|*.tbz|*.tbz2) ${pkgs.gnutar}/bin/tar -cvjf "$@" ;;
      (*.tar.gz|*.tgz) ${pkgs.gnutar}/bin/tar -cvzf "$@" ;;
      (*.tar.lzma|*.tlz) ${pkgs.coreutils}/bin/env XZ_OPT=-T0 ${pkgs.gnutar}/bin/tar --lzma -cvf "$@" ;;
      (*.tar.xz|*.txz) ${pkgs.coreutils}/bin/env XZ_OPT=-T0 ${pkgs.gnutar}/bin/tar -cvJf "$@" ;;
      (*.tar) ${pkgs.gnutar}/bin/tar -cvf "$@" ;;
      (*.zip) ${pkgs.zip}/bin/zip -r "$@" ;;
      (*.zst) ${pkgs.zstd}/bin/zstd -c -T0 "''${@:2}" -o "$1" ;;
      (*.bz|*.bz2) print -u2 "$0: .bzip2 is only useful for single files, and does not capture permissions. Use .tar.bz2" ;;
      (*.gz) print -u2 "$0: .gz is only useful for single files, and does not capture permissions. Use .tar.gz" ;;
      (*.lzma) print -u2 "$0: .lzma is only useful for single files, and does not capture permissions. Use .tar.lzma" ;;
      (*.xz) print -u2 "$0: .xz is only useful for single files, and does not capture permissions. Use .tar.xz" ;;
      (*.Z) print -u2 "$0: .Z is only useful for single files, and does not capture permissions." ;;
      (*) print -u2 "$name: unknown archive type: $1" ;;
    esac
  '';

  unarchive = pkgs.writeScriptBin "unarchive" ''
    #!${pkgs.zsh}/bin/zsh

    readonly name="$(${pkgs.coreutils}/bin/basename "$0")"

    if (( # < 1 )); then
      print -u2 "usage: $name <archive_name.ext>..."
      return 2
    fi

    while (( # > 0 )); do
      case "$1" in
        (*.7z|*.001) ${pkgs.p7zip}/bin/7z x "$1" ;;
        (*.rar) ${pkgs.rar}/bin/unrar "$1" ;;
        (*.tar.bz|*.tar.bz2|*.tbz|*.tbz2) ${pkgs.gnutar}/bin/tar -xvjf "$1" ;;
        (*.tar.gz|*.tgz) ${pkgs.gnutar}/bin/tar -xvzf "$1" ;;
        (*.tar.lzma|*.tlz) ${pkgs.coreutils}/bin/env XZ_OPT=-T0 ${pkgs.gnutar}/bin/tar --lzma -xvf "$1" ;;
        (*.tar.xz|*.txz) ${pkgs.coreutils}/bin/env XZ_OPT=-T0 ${pkgs.gnutar}/bin/tar -xvJf "$1" ;;
        (*.tar) ${pkgs.gnutar}/bin/tar xvf "$1" ;;
        (*.zip) ${pkgs.unzip}/bin/unzip "$1" ;;
        (*.zst) ${pkgs.zstd}/bin/zstd -T0 -d "$1" ;;
        (*.gz) ${pkgs.pigz}/bin/unpigz "$1" ;;
        (*.xz) ${pkgs.xz}/bin/unxz -T0 "$1" ;;
        (*.bz|*.bz2) ${pkgs.pbzip2}/bin/pbunzip2 "$1" ;;
        (*.Z) ${pkgs.gzip}/bin/uncompress "$1" ;;
        (*) print -u2 "$name: unknown archive type: $1" ;;
      esac
      shift
    done
  '';
in
{
  # TODO: remove this after 22.05, this looks like some issue with eval order
  # and my HM 22.05 backports
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "rar"
  ];

  home.packages = [ archive unarchive ];

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

    shellAliases = { "reload!" = "source $HOME/.zshrc"; };

    profileExtra =
      let
        darwinFixes = lib.optionalString pkgs.stdenv.isDarwin ''
          # Source nix-daemon profile since macOS updates can remove it from /etc/zshrc
          # https://github.com/NixOS/nix/issues/3616
          if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
            source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
          fi

          # Fix issue with UTF-8 characters on systems that support
          # UTF-8 correctly but doesn't set the locale for some reason,
          # e.g.: macOS
          [[ -z "$LANG" ]] && export LANG=en_US.UTF-8
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

    initExtra = with pkgs;
      let
        # macOS already has `open`
        open = lib.optionalString (!stdenv.isDarwin) ''
          open() { run-bg ${xdg-utils}/bin/xdg-open "$@" }
        '';
      in
      ''
        # helpers
        run-bg() {
          exec 0>&-
          exec 1>&-
          exec 2>&-
          "$@" &
          disown $!
        }
        ${open}
        get-ip() { ${curl}/bin/curl -Ss "https://ifconfig.me" }
        get-ip!() { ${curl}/bin/curl -Ss "https://ipapi.co/$(get-ip)/yaml" }

        # allow using nix-shell with zsh
        ${pkgs.any-nix-shell}/bin/any-nix-shell zsh --info-right | source /dev/stdin

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

    plugins = with self.inputs; lib.flatten [
      {
        src = zim-completion;
        name = "zim-completion";
        file = "init.zsh";
      }
      {
        src = zim-environment;
        name = "zim-environment";
        file = "init.zsh";
      }
      {
        src = zim-input;
        name = "zim-input";
        file = "init.zsh";
      }
      {
        src = zim-git;
        name = "zim-git";
        file = "init.zsh";
      }
      {
        src = zim-ssh;
        name = "zim-ssh";
        file = "init.zsh";
      }
      {
        src = zim-utility;
        name = "zim-utility";
        file = "init.zsh";
      }
      {
        src = pure;
        name = "pure";
      }
      {
        src = zsh-autopair;
        name = "zsh-autopair";
      }
      {
        src = zsh-completions;
        name = "zsh-completions";
      }
      {
        src = zsh-syntax-highlighting;
        name = "zsh-syntax-highlighting";
      }
      (lib.optional (config.device.type != "server") {
        src = zsh-system-clipboard;
        name = "zsh-system-clipboard";
      })
      # Should be the last one
      {
        src = zsh-history-substring-search;
        name = "zsh-history-substring-search";
      }
    ];
  };

  programs = {
    dircolors.enable = true;
    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
        # TODO: remove this on 22.05
        enableFlakes = lib.mkIf (!pkgs.stdenv.isDarwin) true;
      };
    };
    fzf = {
      enable = true;
      fileWidgetOptions = [ "--preview 'head {}'" ];
      historyWidgetOptions = [ "--sort" ];
    };
  };
}

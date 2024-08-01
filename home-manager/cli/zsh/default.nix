{
  config,
  pkgs,
  lib,
  flake,
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
    # Do not forget to set 'Hack Nerd Mono Font' as the terminal font
    icons.enable = lib.mkEnableOption "icons" // {
      default = config.home-manager.desktop.enable || config.home-manager.darwin.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        get-ip
        realise-symlink
      ]
      ++ lib.optionals (!stdenv.isDarwin) [ (run-bg-alias "open" (lib.getExe' xdg-utils "xdg-open")) ];

    programs.zsh = {
      enable = true;
      autocd = true;
      defaultKeymap = "viins";

      # taken care by zim-completion
      completionInit = "";

      autosuggestion.enable = true;

      history = {
        ignoreDups = true;
        ignoreSpace = true;
        expireDuplicatesFirst = true;
        share = true;
      };

      historySubstringSearch = {
        enable = true;
        searchUpKey = [ "$terminfo[kcuu1]" ];
        searchDownKey = [ "$terminfo[kcud1]" ];
      };

      profileExtra = lib.concatStringsSep "\n" (
        lib.filter (x: x != "") [
          (lib.optionalString config.home-manager.crostini.enable # bash
            ''
              # Force truecolor support in Crostini
              export COLORTERM=truecolor
              # https://github.com/nix-community/home-manager/issues/3711
              export LC_CTYPE=C.UTF-8
            ''
          )
          (lib.optionalString pkgs.stdenv.isDarwin # bash
            ''
              # Source nix-daemon profile since macOS updates can remove it from /etc/zshrc
              # https://github.com/NixOS/nix/issues/3616
              if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
                source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
              fi
              # Set the soft ulimit to something sensible
              # https://developer.apple.com/forums/thread/735798
              ulimit -Sn 524288
            ''
          )
          # bash
          ''
            # Source .profile
            [[ -e ~/.profile ]] && emulate sh -c '. ~/.profile'
          ''
        ]
      );

      initExtraBeforeCompInit = # bash
        ''
          # zimfw config
          zstyle ':zim:input' double-dot-expand no
        '';

      initExtra =
        # manually creating integrations since this is faster than calling
        # the program during startup (e.g. `zoxide init zsh`)
        # bash
        ''
          # any-nix-shell
          source ${
            pkgs.runCommand "any-nix-shell-zsh" { buildInputs = [ pkgs.any-nix-shell ]; } ''
              any-nix-shell zsh > $out
            ''
          }

          # fzf
          source ${config.programs.fzf.package}/share/fzf/completion.zsh
          source ${config.programs.fzf.package}/share/fzf/key-bindings.zsh

          # starship
          source ${
            pkgs.runCommand "starship-zsh" { buildInputs = [ config.programs.starship.package ]; } ''
              starship init zsh > $out
            ''
          }

          # zoxide
          source ${
            pkgs.runCommand "zoxide-init-zsh" { buildInputs = [ config.programs.zoxide.package ]; } ''
              zoxide init zsh > $out
            ''
          }

          # zsh-fast-syntax-highlighting
          source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh

          # try to correct the spelling of commands
          setopt correct
          # disable C-S/C-Q
          setopt noflowcontrol
          # disable "no matches found" check
          unsetopt nomatch
          # disable clock
          unset RPROMPT

          # edit the current command line in $EDITOR
          bindkey -M vicmd v edit-command-line

          # zsh-history-substring-search
          # historySubstringSearch.{searchUpKey,searchDownKey} does not work with
          # vicmd, this is why we have this here
          bindkey -M vicmd 'k' history-substring-search-up
          bindkey -M vicmd 'j' history-substring-search-down

          # allow ad-hoc scripts to be add to PATH locally
          export PATH="$HOME/.local/bin:$PATH"

          # source contents from ~/.zshrc.d/*.zsh
          for file in "$HOME/.zshrc.d/"*.zsh; do
            [[ -f "$file" ]] && source "$file"
          done
        '';

      plugins =
        let
          zshCompilePlugin =
            name: src:
            pkgs.runCommand name
              {
                name = "${name}-zwc";
                nativeBuildInputs = [ pkgs.zsh ];
              }
              ''
                mkdir $out
                cp -rT ${src} $out
                cd $out
                find -name '*.zsh' -execdir zsh -c 'zcompile {}' \;
              '';
          zshPlugin = name: {
            inherit name;
            src = zshCompilePlugin name (builtins.getAttr name flake.inputs);
          };
          zimPlugin = name: zshPlugin name // { file = "init.zsh"; };
        in
        lib.flatten [
          (zimPlugin "zim-input")
          (zimPlugin "zim-utility")
          (zshPlugin "zsh-autopair")
          (zshPlugin "zsh-completions")
          (zimPlugin "zim-completion") # needs to be the last one
        ];

      sessionVariables = {
        # Enable scroll support
        LESS = "--RAW-CONTROL-CHARS";
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

    home.file =
      let
        compileZshConfig =
          filename:
          pkgs.runCommand filename
            {
              name = "${filename}-zwc";
              nativeBuildInputs = [ pkgs.zsh ];
            }
            ''
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
      fzf = {
        enable = true;
        fileWidgetOptions = [ "--preview 'head {}'" ];
        historyWidgetOptions = [ "--sort" ];
        enableZshIntegration = false;
      };
      starship = {
        enable = true;
        enableZshIntegration = false;
        settings = lib.mkMerge [
          (lib.optionalAttrs (!cfg.icons.enable) (lib.importTOML ./starship-plain-text-symbols.toml))
          {
            directory = {
              style = "blue";
              truncate_to_repo = false;
              truncation_length = 0;
            };
            container.disabled = true;
            git_status.stashed = "";
          }
        ];
      };
      zoxide = {
        enable = true;
        enableZshIntegration = false;
      };
    };
  };
}

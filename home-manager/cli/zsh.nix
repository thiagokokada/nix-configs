{ config, pkgs, lib, flake, ... }:

let
  get-ip = pkgs.writeShellScriptBin "get-ip" ''
    ${lib.getExe pkgs.curl} -Ss "https://ifconfig.me"
  '';
  get-ip' = pkgs.writeShellScriptBin "get-ip!" ''
    ${lib.getExe pkgs.curl} -Ss "https://ipapi.co/$(${lib.getExe get-ip})/yaml"
  '';
  remove-symlink = pkgs.writeShellScriptBin "remove-symlink" ''
    [[ -L "$1" ]] && \
      ${lib.getExe' pkgs.coreutils "cp"} --remove-destination \
      "$(${lib.getExe' pkgs.coreutils "readlink"} "$1")" "$1"
  '';
in
{
  options.home-manager.cli.zsh.enable = lib.mkEnableOption "ZSH config" // {
    default = config.home-manager.cli.enable;
  };

  config = lib.mkIf config.home-manager.cli.zsh.enable {
    home.packages = with pkgs; [
      get-ip
      get-ip'
      remove-symlink
    ] ++ lib.optionals (!stdenv.isDarwin) [
      (run-bg-alias "open" (lib.getExe' xdg-utils "xdg-open"))
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

      historySubstringSearch = {
        enable = true;
        searchUpKey = [ "$terminfo[kcuu1]" ];
        searchDownKey = [ "$terminfo[kcud1]" ];
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

      profileExtra = ''
        # Source .profile
        [[ -e ~/.profile ]] && emulate sh -c '. ~/.profile'
      '' + lib.optionalString pkgs.stdenv.isDarwin ''
        # Source nix-daemon profile since macOS updates can remove it from /etc/zshrc
        # https://github.com/NixOS/nix/issues/3616
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          source '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi
        # Set the soft ulimit to something sensible
        # https://developer.apple.com/forums/thread/735798
        ulimit -Sn 524288
      '';

      initExtraBeforeCompInit = ''
        # zimfw config
        zstyle ':zim:input' double-dot-expand no
        zstyle ':zim:ssh' ids /dev/null
      '';

      initExtra = /* bash */ ''
        # avoid duplicated entries in PATH
        typeset -U PATH

        # try to correct the spelling of commands
        setopt correct
        # disable C-S/C-Q
        setopt noflowcontrol
        # disable "no matches found" check
        unsetopt nomatch

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
      eza = {
        enable = true;
        enableAliases = true;
        git = true;
      };
      fzf = {
        enable = true;
        fileWidgetOptions = [ "--preview 'head {}'" ];
        historyWidgetOptions = [ "--sort" ];
      };
      zoxide.enable = true;
    };
  };
}

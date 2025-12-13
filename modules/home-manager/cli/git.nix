{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.home-manager.cli.git;
in
{
  options.home-manager.cli.git = {
    enable = lib.mkEnableOption "Git config" // {
      default = config.home-manager.cli.enable;
    };
    gh.enable = lib.mkEnableOption "GitHub CLI config" // {
      default = true;
    };
    gui.enable = lib.mkEnableOption "Git GUI config " // {
      default = config.home-manager.desktop.enable || config.home-manager.darwin.enable;
    };
    mergiraf.enable = lib.mkEnableOption "Mergiraf config" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages =
        with pkgs;
        lib.optionals cfg.gui.enable [
          (run-bg-alias "gk" (lib.getExe pkgs.gitk-go))
          gitk-go
        ]
        ++ lib.optionals cfg.mergiraf.enable [
          mergiraf
        ];
      shellAliases = {
        g = "git";
        gui = "gitui";
      };
    };

    programs = {
      gh = {
        inherit (cfg.gh) enable;
        extensions = with pkgs; [
          gh-dash
          gh-markdown-preview
          gh-gfm-preview
        ];
        settings = {
          git_protocol = "ssh";
          editor = "nvim";
          prompt = "enabled";
          aliases = {
            co = "pr checkout";
          };
        };
      };

      git = {
        enable = true;
        package =
          with pkgs;
          if cfg.gui.enable then
            gitFull.override {
              # Disable unnecessary features since this will generate a rebuild
              svnSupport = !stdenv.isDarwin;
              sendEmailSupport = !stdenv.isDarwin;
              # Use SSH from macOS instead with support for Keyring
              # https://github.com/NixOS/nixpkgs/issues/62353
              withSsh = !stdenv.isDarwin;
            }
          else
            git;

        attributes = lib.mkIf cfg.mergiraf.enable [
          "* merge=mergiraf"
        ];

        ignores = [
          "**/.claude/settings.local.json"
          "**/CLAUDE.local.md"
          "*.swp"
          "*~"
          ".bsp/sbt.json"
          ".clj-kondo"
          ".dir-locals.el"
          ".DS_Store"
          ".lsp"
          ".projectile"
          "Thumbs.db"
        ];

        includes = [ { path = "~/.config/git/local"; } ];

        # https://blog.gitbutler.com/how-git-core-devs-configure-git/
        settings = {
          alias = {
            branch-default = ''!git symbolic-ref --short refs/remotes/origin/HEAD | sed "s|^origin/||"'';
            checkout-default = ''!git checkout "$(git branch-default)"'';
            rebase-default = ''!git rebase "$(git branch-default)"'';
            merge-default = ''!git merge "$(git branch-default)"'';
            branch-cleanup = ''!git branch --merged | egrep -v "(^\*|master|main|dev|development)" | xargs git branch -d #'';
            # Restores the commit message from a failed commit for some reason
            fix-commit = ''!git commit -F "$(git rev-parse --git-dir)/COMMIT_EDITMSG" --edit'';
            pushf = "push --force-with-lease";
            logs = "log --show-signature";
          };
          init.defaultBranch = "main";
          branch.sort = "-committerdate";
          color.ui = true;
          column.ui = "auto";
          commit.verbose = true;
          core = {
            editor = "nvim";
            whitespace = "trailing-space,space-before-tab,indent-with-non-tab";
          };
          checkout = {
            defaultRemote = "origin";
          };
          diff = {
            algorithm = "histogram";
            colorMoved = "plain";
            mnemonicPrefix = true;
            renames = true;
          };
          fetch = {
            prune = true;
            pruneTags = true;
          };
          github = {
            user = "thiagokokada";
          };
          merge = {
            mergiraf = lib.mkIf cfg.mergiraf.enable {
              name = "mergiraf";
              driver = "mergiraf merge --git %O %A %B -s %S -x %X -y %Y -p %P -l %L";
            };
            conflictstyle = if cfg.mergiraf.enable then "diff3" else "zdiff3";
            tool = "nvim -d";
          };
          pull.rebase = true;
          push = {
            autoSetupRemote = true;
            followTags = true;
            default = "simple";
          };
          rebase = {
            autoSquash = true;
            autoStash = true;
            updateRefs = true;
          };
          rerere = {
            enabled = true;
            autoupdate = true;
          };
          tag.sort = "-version:refname";
          user = {
            name = config.meta.fullname;
            inherit (config.meta) email;
          };
          safe.bareRepository = "explicit";
        };
      };

      gitui = {
        # Broken in darwin for now
        # https://github.com/NixOS/nixpkgs/issues/450861
        enable = pkgs.stdenv.isLinux;
        keyConfig = builtins.readFile (
          pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/extrawurst/gitui/8876c1d0f616d55a0c0957683781fd32af815ae3/vim_style_key_config.ron";
            hash = "sha256-uYL9CSCOlTdW3E87I7GsgvDEwOPHoz1LIxo8DARDX1Y=";
          }
        );
        theme = builtins.readFile (
          pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/catppuccin/gitui/c7661f043cb6773a1fc96c336738c6399de3e617/themes/catppuccin-macchiato.ron";
            hash = "sha256-tmRc/8hpWVo2FIsnAShWoM4Lfpx3WoENt6gF4J+JlRA=";
          }
        );
      };
    };
  };
}

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
    gui.enable = lib.mkEnableOption "Git GUIconfig " // {
      default = config.home-manager.desktop.enable || config.home-manager.darwin.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages =
        with pkgs;
        lib.optionals cfg.gui.enable [
          (run-bg-alias "gk" (lib.getExe' config.programs.git.package "gitk"))
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
        userName = config.meta.fullname;
        userEmail = config.meta.email;
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

        delta = {
          enable = true;
          options = {
            features = "side-by-side line-numbers decorations";
            syntax-theme = "Dracula";
            plus-style = ''syntax "#003800"'';
            minus-style = ''syntax "#3f0001"'';
            decorations = {
              commit-decoration-style = "bold yellow box ul";
              file-style = "bold yellow ul";
              file-decoration-style = "none";
              hunk-header-decoration-style = "cyan box ul";
            };
            delta = {
              navigate = true;
            };
            line-numbers = {
              line-numbers-left-style = "cyan";
              line-numbers-right-style = "cyan";
              line-numbers-minus-style = 124;
              line-numbers-plus-style = 28;
            };
          };
        };

        aliases = {
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

        ignores = [
          "*.swp"
          "*~"
          ".clj-kondo"
          ".dir-locals.el"
          ".DS_Store"
          ".lsp"
          ".projectile"
          "Thumbs.db"
        ];

        includes = [ { path = "~/.config/git/local"; } ];

        # https://blog.gitbutler.com/how-git-core-devs-configure-git/
        extraConfig = {
          init.defaultBranch = "main";
          branch.sort = "-committerdate";
          color.ui = true;
          column.ui = "auto";
          commit.verbose = true;
          core = {
            editor = "nvim";
            untrackedCache = true;
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
            conflictstyle = "zdiff3";
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
          safe.bareRepository = "explicit";
        };
      };

      gitui = {
        enable = true;
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

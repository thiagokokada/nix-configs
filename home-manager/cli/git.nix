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
      default = config.home-manager.desktop.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages =
        with pkgs;
        lib.optionals cfg.gh.enable [ github-cli ]
        ++ lib.optionals cfg.gui.enable [
          (run-bg-alias "gcd" "${lib.getExe git-cola} dag")
          (run-bg-alias "gk" (lib.getExe' config.programs.git.package "gitk"))
          git-cola
        ];
      shellAliases = {
        g = "git";
        gui = "gitui";
      };
    };

    programs = {
      gh = {
        enable = true;
        extensions = with pkgs; [
          gh-dash
          gh-markdown-preview
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

        userName = config.mainUser.fullname;
        userEmail = config.mainUser.email;
        package =
          with pkgs;
          if cfg.gui.enable then
            gitFull.override {
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

        extraConfig = {
          init = {
            defaultBranch = "master";
          };
          branch = {
            sort = "-committerdate";
          };
          color = {
            ui = true;
          };
          commit = {
            verbose = true;
          };
          core = {
            editor = "nvim";
            whitespace = "trailing-space,space-before-tab,indent-with-non-tab";
          };
          checkout = {
            defaultRemote = "origin";
          };
          github = {
            user = "thiagokokada";
          };
          merge = {
            conflictstyle = "zdiff3";
            tool = "nvim -d";
          };
          pull = {
            rebase = true;
          };
          push = {
            autoSetupRemote = true;
            default = "simple";
          };
          rebase = {
            autoStash = true;
          };
          tag.sort = "-version:refname";
        };
      };

      gitui = {
        enable = true;
        # https://github.com/extrawurst/gitui/blob/master/vim_style_key_config.ron
        keyConfig = # rust
          ''
            // Note:
            // If the default key layout is lower case,
            // and you want to use `Shift + q` to trigger the exit event,
            // the setting should like this `exit: Some(( code: Char('Q'), modifiers: "SHIFT")),`
            // The Char should be upper case, and the modifier should be set to "SHIFT".
            //
            // Note:
            // find `KeysList` type in src/keys/key_list.rs for all possible keys.
            // every key not overwritten via the config file will use the default specified there
            (
                open_help: Some(( code: F(1), modifiers: "")),

                move_left: Some(( code: Char('h'), modifiers: "")),
                move_right: Some(( code: Char('l'), modifiers: "")),
                move_up: Some(( code: Char('k'), modifiers: "")),
                move_down: Some(( code: Char('j'), modifiers: "")),

                popup_up: Some(( code: Char('p'), modifiers: "CONTROL")),
                popup_down: Some(( code: Char('n'), modifiers: "CONTROL")),
                page_up: Some(( code: Char('b'), modifiers: "CONTROL")),
                page_down: Some(( code: Char('f'), modifiers: "CONTROL")),
                home: Some(( code: Char('g'), modifiers: "")),
                end: Some(( code: Char('G'), modifiers: "SHIFT")),
                shift_up: Some(( code: Char('K'), modifiers: "SHIFT")),
                shift_down: Some(( code: Char('J'), modifiers: "SHIFT")),

                edit_file: Some(( code: Char('I'), modifiers: "SHIFT")),

                status_reset_item: Some(( code: Char('U'), modifiers: "SHIFT")),

                diff_reset_lines: Some(( code: Char('u'), modifiers: "")),
                diff_stage_lines: Some(( code: Char('s'), modifiers: "")),

                stashing_save: Some(( code: Char('w'), modifiers: "")),
                stashing_toggle_index: Some(( code: Char('m'), modifiers: "")),

                stash_open: Some(( code: Char('l'), modifiers: "")),

                abort_merge: Some(( code: Char('M'), modifiers: "SHIFT")),
            )
          '';
        # https://github.com/catppuccin/gitui/blob/main/theme/macchiato.ron
        theme = # rust
          ''
            (
                selected_tab: Some(Reset),
                command_fg: Some(Rgb(202, 211, 245)),
                selection_bg: Some(Rgb(91, 96, 120)),
                selection_fg: Some(Rgb(202, 211, 245)),
                cmdbar_bg: Some(Rgb(30, 32, 48)),
                cmdbar_extra_lines_bg: Some(Rgb(30, 32, 48)),
                disabled_fg: Some(Rgb(128, 135, 162)),
                diff_line_add: Some(Rgb(166, 218, 149)),
                diff_line_delete: Some(Rgb(237, 135, 150)),
                diff_file_added: Some(Rgb(238, 212, 159)),
                diff_file_removed: Some(Rgb(238, 153, 160)),
                diff_file_moved: Some(Rgb(198, 160, 246)),
                diff_file_modified: Some(Rgb(245, 169, 127)),
                commit_hash: Some(Rgb(183, 189, 248)),
                commit_time: Some(Rgb(184, 192, 224)),
                commit_author: Some(Rgb(125, 196, 228)),
                danger_fg: Some(Rgb(237, 135, 150)),
                push_gauge_bg: Some(Rgb(138, 173, 244)),
                push_gauge_fg: Some(Rgb(36, 39, 58)),
                tag_fg: Some(Rgb(244, 219, 214)),
                branch_fg: Some(Rgb(139, 213, 202))
            )
          '';
      };
    };
  };
}

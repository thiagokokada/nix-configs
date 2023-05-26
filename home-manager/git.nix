{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    (run-bg-alias "gk" "${config.programs.git.package}/bin/gitk")
    (run-bg-alias "gcd" "${git-cola}/bin/git-cola dag")
    git-cola
    github-cli
  ];

  programs.git = {
    enable = true;

    userName = "Thiago Kenji Okada";
    userEmail = "thiagokokada@gmail.com";
    package = pkgs.gitFull.override {
      # Use SSH from macOS instead with support for Keyring
      # https://github.com/NixOS/nixpkgs/issues/62353
      withSsh = !pkgs.stdenv.isDarwin;
    };

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

    includes = [{ path = "~/.config/git/local"; }];

    extraConfig = {
      init = { defaultBranch = "master"; };
      branch = { sort = "-committerdate"; };
      color = { ui = true; };
      commit = { verbose = true; };
      core = {
        editor = "nvim";
        whitespace = "trailing-space,space-before-tab,indent-with-non-tab";
      };
      checkout = { defaultRemote = "origin"; };
      github = { user = "thiagokokada"; };
      merge = {
        conflictstyle = "zdiff3";
        tool = "nvim -d";
      };
      pull = { rebase = true; };
      push = {
        autoSetupRemote = true;
        default = "simple";
      };
      rebase = { autoStash = true; };
    };
  };
}

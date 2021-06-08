{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [ github-cli ];

  programs.git = {
    enable = true;

    userName = "Thiago Kenji Okada";
    userEmail = "thiagokokada@gmail.com";
    package = pkgs.gitFull;

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
      branch-cleanup = ''!git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d #'';
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
      branch = { sort = "-committerdate"; };
      color = { ui = true; };
      commit = { verbose = true; };
      core = {
        editor = "nvim";
        whitespace = "trailing-space,space-before-tab,indent-with-non-tab";
      };
      checkout = { defaultRemote = "origin"; };
      github = { user = "thiagokokada"; };
      merge = { tool = "nvim -d"; };
      pull = { rebase = true; };
      push = { default = "simple"; };
      rebase = { autoStash = true; };
    };
  };

  programs.zsh.shellAliases = { gk = "run-bg gitk"; };
}

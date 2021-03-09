{ config, lib, pkgs, ... }:

{
  programs.git = {
    enable = true;

    userName = "Thiago Kenji Okada";
    userEmail = "thiagokokada@gmail.com";
    package = pkgs.gitFull;

    aliases = {
      branch-cleanup = ''
        !git branch --merged | egrep -v "(^\*|master|dev)" | xargs git branch -d #'';
      pushf = "push --force-with-lease";
      logs = "log --show-signature";
    };

    ignores = [
      "*.swp"
      "*~"
      ".DS_Store"
      ".dir-locals.el"
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
        whitespace = "trailing-space,space-before-tab,indent-with-non-tab";
        excludesfile = "~/.config/git/ignore_local";
      };
      checkout = { defaultRemote = "origin"; };
      github = { user = "thiagokokada"; };
      merge = { tool = "nvim -d"; };
      pull = { rebase = true; };
      push = { default = "simple"; };
      rebase = { autoStash = true; };
    };
  };

  programs.gh = {
    enable = true;
    editor = "nvim";
    gitProtocol = "ssh";
  };

  programs.zsh.shellAliases = { gk = "run-bg gitk"; };
}

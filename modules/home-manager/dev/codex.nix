{ config, lib, ... }:

let
  cfg = config.home-manager.dev.codex;

  basicPrefixRules = [
    [ "pwd" ]
    [ "ls" ]
    [ "find" ]
    [ "grep" ]
    [ "rg" ]
    [ "cat" ]
    [ "sed" ]
    [ "head" ]
    [ "tail" ]
    [ "wc" ]
    [ "file" ]
    [ "stat" ]
    [ "which" ]
    [ "diff" ]
    [
      "nix"
      "build"
    ]
    [
      "nix"
      "flake"
    ]
    [
      "nix"
      "fmt"
    ]
    [
      "nix"
      "eval"
    ]
    [
      "git"
      "status"
    ]
    [
      "git"
      "diff"
    ]
    [
      "git"
      "log"
    ]
    [
      "git"
      "show"
    ]
    [
      "git"
      "branch"
    ]
    [
      "git"
      "rev-parse"
    ]
    [
      "git"
      "ls-files"
    ]
    [
      "git"
      "remote"
      "-v"
    ]
    [
      "git"
      "stash"
      "list"
    ]
    [
      "gh"
      "pr"
    ]
    [
      "gh"
      "issue"
      "edit"
    ]
    [
      "gh"
      "repo"
      "view"
    ]
  ];

  renderPrefixRule = pattern: ''prefix_rule(pattern=${builtins.toJSON pattern}, decision="allow")'';
in
{
  options.home-manager.dev.codex.enable = lib.mkEnableOption "Codex config" // {
    default = config.home-manager.dev.enable;
  };

  config = lib.mkIf cfg.enable {
    programs.codex = {
      enable = true;
      settings = { };
    };

    home.file.".codex/rules/basic.rules".text =
      lib.concatMapStringsSep "\n" renderPrefixRule basicPrefixRules + "\n";
  };
}

{ pkgs, lib, ... }:
{
  projectRootFile = "flake.nix";

  programs = {
    jsonfmt.enable = true;
    nixfmt.enable = true;
    ruff-check.enable = true;
    ruff-format.enable = true;
    shellcheck.enable = true;
    shfmt.enable = true;
    statix = {
      enable = true;
      disabled-lints = [
        "empty_pattern"
        "repeated_keys"
      ];
    };
  };

  settings = {
    global.excludes = [
      "LICENSE"
      "*.md"
      "*.plist"
      "*.toml"
      "*.zsh"
      "modules/home-manager/editor/emacs/doom-emacs/*"
      # auto-generated
      ".github/workflows/*.yml"
    ];
    formatter = {
      github-actions = {
        command = lib.getExe pkgs.generate-gh-actions;
        includes = [ "actions/*.nix" ];
        priority = 1;
      };
      ruff-format.includes = [
        "*.py"
        "*.pyi"
        # VapourSynth files
        "*.vpy"
        "*.vpyi"
      ];
    };
  };
}

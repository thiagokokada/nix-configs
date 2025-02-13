{ ... }:
{
  projectRootFile = "flake.nix";

  programs = {
    nixfmt.enable = true;
    ruff-format.enable = true;
    ruff-check.enable = true;
    jsonfmt.enable = true;
    shfmt.enable = true;
    shellcheck.enable = true;
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

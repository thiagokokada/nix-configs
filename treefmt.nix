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
      github-actions =
        let
          mkGHActionsYAML =
            name:
            pkgs.runCommand "make-${name}-yaml"
              {
                buildInputs = with pkgs; [
                  actionlint
                  yj
                ];
                json = builtins.toJSON (import ./actions/${name}.nix);
                passAsFile = [ "json" ];
              }
              ''
                mkdir -p $out
                yj -jy < "$jsonPath" > $out/${name}.yml
                actionlint -verbose $out/${name}.yml
              '';
          generateGhActions =
            let
              ghActionsYAMLs = map mkGHActionsYAML [
                "build-and-cache"
                "update-flakes"
                "update-flakes-after"
                "validate-flakes"
              ];
              resultDir = ".github/workflows";
            in
            pkgs.writeShellApplication {
              name = "generate-gh-actions";
              text = ''
                rm -rf "${resultDir}"
                mkdir -p "${resultDir}"
                for dir in ${builtins.toString ghActionsYAMLs}; do
                  cp -f $dir/*.yml "${resultDir}"
                done
                echo Done!
              '';
            };

        in
        {
          command = lib.getExe generateGhActions;
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

{ pkgs, lib, ... }:
{
  projectRootFile = "flake.nix";

  programs = {
    deadnix.enable = true;
    jsonfmt.enable = true;
    nixfmt.enable = true;
    ruff-check.enable = true;
    ruff-format.enable = true;
    shellcheck.enable = true;
    shfmt.enable = true;
    yamllint = {
      enable = true;
      settings = {
        line-length = false;
      };
    };
    statix.enable = true;
  };

  settings = {
    global.excludes = [
      "LICENSE"
      "*.md"
      "*.plist"
      "*.toml"
      "*.zsh"
      # auto-generated
      ".github/workflows/*.yml"
      # third-party
      "ansible/roles/luizgavalda.gnome_extensions/**/*.yml"
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
                for dir in ${toString ghActionsYAMLs}; do
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

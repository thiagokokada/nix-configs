let
  constants = import ./constants.nix;
  utils = import ./utils.nix;
  sharedNixFlags = [ "--print-build-logs" ];
in
with constants;
with utils;
rec {
  freeDiskSpaceStep = {
    uses = actions.free-disk-space;
    "with" = {
      opt = true;
      tool-cache = true;
      usrlocal = true;
      usrmisc = true;
    };
  };

  checkoutStep = {
    uses = actions.checkout;
  };

  installNixActionStep = {
    uses = actions.install-nix-action;
    "with" = {
      # Need to define a channel, otherwise it will use bash from environment
      nix_path = "nixpkgs=channel:nixos-unstable";
      extra_nix_config = builtins.concatStringsSep "\n" [
        "accept-flake-config = true"
        # Should avoid GitHub API rate limit
        "access-tokens = github.com=${escapeGhVar "secrets.GITHUB_TOKEN"}"
      ];
    };
  };

  cachixActionStep = {
    uses = actions.cachix-action;
    "with" = {
      name = "thiagokokada-nix-configs";
      extraPullNames = builtins.concatStringsSep "," [
        "nix-community"
        "chaotic-nyx"
      ];
      authToken = escapeGhVar "secrets.CACHIX_TOKEN";
    };
  };

  withSharedSteps =
    steps:
    [
      checkoutStep
      installNixActionStep
      cachixActionStep
    ]
    ++ steps;

  validateFlakesStep = {
    name = "Validate Flakes";
    run = "nix flake check --all-systems ${toString sharedNixFlags}";
  };

  buildNixDarwinConfigurations =
    {
      hostNames ? [ ],
      extraNixFlags ? [ ],
    }:
    {
      name = "Build nix-darwin configs for: ${builtins.concatStringsSep ", " hostNames}";
      run = builtins.concatStringsSep "\n" (
        map (
          hostName:
          "nix build ${
            toString (sharedNixFlags ++ extraNixFlags)
          } '.#darwinConfigurations.${hostName}.system'"
        ) hostNames
      );
    };

  buildHomeManagerConfigurations =
    {
      hostNames ? [ ],
      extraNixFlags ? [ ],
    }:
    {
      name = "Build Home-Manager configs for: ${builtins.concatStringsSep ", " hostNames}";
      run = builtins.concatStringsSep "\n" (
        map (
          hostName:
          "nix build ${
            toString (sharedNixFlags ++ extraNixFlags)
          } '.#homeConfigurations.${hostName}.activationPackage'"
        ) hostNames
      );
    };

  buildNixOSConfigurations =
    {
      hostNames ? [ ],
      extraNixFlags ? [ ],
    }:
    {
      name = "Build NixOS configs for: ${builtins.concatStringsSep ", " hostNames}";
      run = builtins.concatStringsSep "\n" (
        map (
          hostName:
          "nix build ${
            toString (sharedNixFlags ++ extraNixFlags)
          } '.#nixosConfigurations.${hostName}.config.system.build.toplevel'"
        ) hostNames
      );
    };

  updateFlakeLockStep = {
    name = "Update flake.lock";
    run = ''
      git config user.name "${escapeGhVar "github.actor"}"
      git config user.email "${escapeGhVar "github.actor"}@users.noreply.github.com"
      nix flake update --commit-lock-file
    '';
  };

  createPullRequestStep = {
    name = "Create Pull Request";
    uses = actions.create-pull-request;
    "with" = {
      branch = "flake-updates";
      delete-branch = true;
      title = "Update flake.lock";
      body = ''
        ## Run report

        https://github.com/${escapeGhVar "github.repository"}/actions/runs/${escapeGhVar "github.run_id"}
      '';
    };
  };

  concurrency = {
    group = "${escapeGhVar "github.workflow"}-${escapeGhVar "github.event.pull_request.number || github.ref"}";
    cancel-in-progress = true;
  };
}

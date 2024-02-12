let
  constants = import ./constants.nix;
  nixFlags = [ "--print-build-logs" ];
in
with constants;
{
  freeDiskSpaceStep = {
    uses = actions.free-disk-space;
    "with" = {
      swap-storage = false;
      tool-cache = true;
    };
  };
  checkoutStep = {
    uses = actions.checkout;
  };
  installNixActionStep = { extraNixConfig ? [ ] }: {
    uses = actions.install-nix-action;
    "with" = {
      # Need to define a channel, otherwise it will use bash from environment
      nix_path = "nixpkgs=channel:nixos-unstable";
      extra_nix_config = builtins.concatStringsSep "\n" (
        [
          "accept-flake-config = true"
          # Should avoid GitHub API rate limit
          "access-tokens = github.com=\${{ secrets.GITHUB_TOKEN }}"
        ]
        ++ extraNixConfig
      );
    };
  };
  cachixActionStep = {
    uses = actions.cachix-action;
    "with" = {
      name = "thiagokokada-nix-configs";
      extraPullNames = "nix-community";
      authToken = "\${{ secrets.CACHIX_TOKEN }}";
    };
  };
  validateFlakesStep = {
    name = "Validate Flakes";
    run = "nix flake check ${toString nixFlags}";
  };
  buildHomeManagerConfigurations = { hostnames ? [ ], extraNixFlags ? [ ] }: {
    name = "Build Home-Manager configs for: ${builtins.concatStringsSep ", " hostnames}";
    run = builtins.concatStringsSep "\n"
      (map
        (hostname: "nix build ${toString (nixFlags ++ extraNixFlags)} '.#homeConfigurations.${hostname}.activationPackage'")
        hostnames);
  };
  buildNixOSConfigurations = { hostnames ? [ ], extraNixFlags ? [ ] }: {
    name = "Build NixOS configs for: ${builtins.concatStringsSep ", " hostnames}";
    run = builtins.concatStringsSep "\n"
      (map
        (hostname: "nix build ${toString (nixFlags ++ extraNixFlags)} '.#nixosConfigurations.${hostname}.config.system.build.toplevel'")
        hostnames);
  };
  updateFlakeLockStep = {
    name = "Update flake.lock";
    run = ''
      git config user.name "''${{ github.actor }}"
      git config user.email "''${{ github.actor }}@users.noreply.github.com"
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

        https://github.com/''${{ github.repository }}/actions/runs/''${{ github.run_id }}
      '';
    };
  };
  installUbuntuPackages = packages: {
    name = "Install Ubuntu packages: ${builtins.concatStringsSep ", " packages}";
    run = ''
      DEBIAN_FRONTEND=noninteractive
      sudo apt-get update -q -y
      sudo apt-get install -q -y ${toString packages}
    '';
  };
}

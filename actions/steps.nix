let
  constants = import ./constants.nix;
  nixFlags = [ "--print-build-logs" ];
in
with constants;
{
  maximimizeBuildSpaceStep = {
    uses = actions.maximize-build-space;
    "with" = {
      remove-dotnet = true;
      remove-android = true;
      remove-haskell = true;
      remove-codeql = true;
      remove-docker-images = true;
      overprovision-lvm = true;
      root-reserve-mb = 512;
      swap-size-mb = 1024;
    };
  };
  checkoutStep = {
    uses = actions.checkout;
  };
  installNixActionStep = {
    uses = actions.install-nix-action;
    "with" = {
      # Need to define a channel, otherwise it wiill use bash from environment
      nix_path = "nixpkgs=channel:nixos-unstable";
      # Should avoid GitHub API rate limit
      extra_nix_config = "access-tokens = github.com=\${{ secrets.GITHUB_TOKEN }}";
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
  setDefaultGitBranchStep = {
    name = "Set default git branch (to reduce log spam)";
    run = "git config --global init.defaultBranch master";
  };
  checkNixStep = {
    name = "Check if all `.nix` files are formatted correctly";
    run = "nix run '.#formatCheck'";
  };
  validateFlakesStep = {
    name = "Validate Flakes";
    run = "nix flake check";
  };
  buildHomeManagerConfigurations = { hostnames ? constants.home-manager.linux.hostnames, extraNixFlags ? [ ] }: {
    name = "Build Home-Manager configs for: ${builtins.concatStringsSep ", " hostnames}";
    run = builtins.concatStringsSep "\n"
      (map
        (hostname: "nix build ${toString (nixFlags ++ extraNixFlags)} '.#homeConfigurations.${hostname}.activationPackage'")
        hostnames);
  };
  buildNixOSConfigurations = { hostnames ? constants.nixos.hostnames, extraNixFlags ? [ ] }: {
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
  diffNixOutputs = id: old: new: {
    inherit id;
    name = "Diff Nix outputs: ${old} vs ${new}";
    uses = actions.command-output;
    "with".run = ''
      nix run github:NixOS/nixpkgs/nixos-unstable#nvd -- --color never diff '${old}' '${new}'
    '';
  };
  createPullRequestStep = diffIds: {
    name = "Create Pull Request";
    uses = actions.create-pull-request;
    "with" = {
      branch = "flake-updates";
      delete-branch = true;
      title = "Update flake.lock";
      body = ''
        ## Run report

        https://github.com/''${{ github.repository }}/actions/runs/''${{ github.run_id }}
      '' +
      (builtins.concatStringsSep "\n"
        (map
          (id: ''

            ## Changes for ${id}

            ```bash
            ''${{ steps.${id}.outputs.stdout }}
            ```
          '')
          diffIds));
    };
  };
}

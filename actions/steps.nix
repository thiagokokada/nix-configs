let
  constants = import ./constants.nix;
  nixFlags = toString [ "--print-build-logs" ];
in
with constants;
{
  maximimizeBuildSpaceStep = {
    uses = actions.maximize-build-space;
    "with" = {
      remove-dotnet = true;
      remove-android = true;
      remove-haskell = true;
      overprovision-lvm = true;
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
  buildHomeManagerConfigurations = hostnames: {
    name = "Build Home-Manager configs";
    run = builtins.concatStringsSep "\n"
      (map
        (hostname: "nix build ${nixFlags} '.#homeConfigurations.${hostname}.activationPackage'")
        hostnames);
  };
  buildNixOSConfigurationWithOutput = hostname: output: {
    name = "Build NixOS config for '${hostname}' in '${output}'";
    run = ''
      nix build ${nixFlags} -o ${output} '.#nixosConfigurations.${hostname}.config.system.build.toplevel'
    '';
  };
  buildNixOSConfigurations = hostnames: {
    name = "Build NixOS configs";
    run = builtins.concatStringsSep "\n"
      (map
        (hostname: "nix build ${nixFlags} '.#nixosConfigurations.${hostname}.config.system.build.toplevel'")
        hostnames);
  };
  buildNixDarwinConfigurations = hostnames: {
    name = "Build NixOS configs";
    run = builtins.concatStringsSep "\n"
      (map
        (hostname: "nix build ${nixFlags} '.#darwinConfigurations.${hostname}.system'")
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
    name = "Diff Nix outputs: '${old}' vs '${new}'";
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
  cacheNixStore = {
    name = "Cache /nix/store";
    uses = actions.cache;
    "with" = {
      path = "/tmp/nix-cache";
      key = ''''${{ runner.os }}-''${{ runner.arch }}-''${{ hashFiles('flake.*') }}'';
      restore-keys = ''
        ''${{ runner.os }}-''${{ runner.arch }}-''${{ hashFiles('flake.*') }}
        ''${{ runner.os }}-''${{ runner.arch }}-
      '';
    };
  };
  importNixStoreCache = {
    name = "Import /nix/store cache";
    run = ''
      if [[ -f "/tmp/nix-cache" ]]; then
        nix-store --import < "/tmp/nix-cache"
      fi
    '';
  };
  exportNixStoreCache = {
    name = "Export /nix/store cache";
    run = ''
      nix-collect-garbage --delete-older-than 7d
      nix-store --export $(find "/nix/store" -maxdepth 1 -name '*-*') > "/tmp/nix-cache"
    '';
  };
}

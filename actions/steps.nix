let
  constants = import ./constants.nix;
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
        (hostname: "nix build '.#homeConfigurations.${hostname}.activationPackage'")
        hostnames);
  };
  buildNixOSConfigurations = hostnames: {
    name = "Build NixOS configs";
    run = builtins.concatStringsSep "\n"
      (map
        (hostname: "nix build '.#nixosConfigurations.${hostname}.config.system.build.toplevel'")
        hostnames);
  };
  buildNixDarwinConfigurations = hostnames: {
    name = "Build NixOS configs";
    run = builtins.concatStringsSep "\n"
      (map
        (hostname: "nix build '.#darwinConfigurations.${hostname}.system'")
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
    uses = "peter-evans/create-pull-request@v4";
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
}

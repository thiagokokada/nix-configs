let
  constants = import ./constants.nix;
in
{
  maximimizeBuildSpaceStep = {
    uses = "easimon/maximize-build-space@v6";
    "with" = {
      remove-dotnet = true;
      remove-android = true;
      remove-haskell = true;
      overprovision-lvm = true;
    };
  };
  checkoutStep = {
    uses = "actions/checkout@v3";
    # Nix Flakes doesn't work on shallow clones
    "with".fetch-depth = 0;
  };
  installNixActionStep = {
    uses = "cachix/install-nix-action@v17";
    "with" = {
      # Need to define a channel, otherwise it wiill use bash from environment
      nix_path = "nixpkgs=channel:nixos-unstable";
      # Should avoid GitHub API rate limit
      extra_nix_config = "access-tokens = github.com=\${{ secrets.GITHUB_TOKEN }}";
    };
  };
  cachixActionStep = {
    uses = "cachix/cachix-action@v10";
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
  updateFlakeLockStep = {
    name = "Update flake.lock";
    run = ''
      git config user.name "''${{ github.actor }}"
      git config user.email "''${{ github.actor }}@users.noreply.github.com"
      nix flake update --commit-lock-file
    '';
  };
  buildNixDarwinConfigs = { hostnames ? constants.NixDarwin.hostnames }: {
    name = "Building nix-darwin configs";
    run =
      let
        buildNixDarwinConfig = (h: "nix build '#darwinConfigurations.${h}.system'");
      in
      builtins.concatStringsSep "\n" (map buildNixDarwinConfig hostnames);
  };
  buildNixOSConfigs = { hostnames ? constants.NixOS.hostnames }: {
    name = "Building NixOS configs";
    run =
      let
        buildNixOSConfig = (h: "nix build '#nixosConfigurations.${h}.config.system.build.toplevel'");
      in
      builtins.concatStringsSep "\n" (map buildNixOSConfig hostnames);
  };
  buildHomeManagerConfigs = { hostnames ? constants.HomeManager.linux.hostnames }: {
    name = "Building Home-Manager configs";
    run =
      let
        buildHMConfig = (h: "nix build '#homeConfigurations.${h}.activationPackage'");
      in
      builtins.concatStringsSep "\n" (map buildHMConfig hostnames);
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

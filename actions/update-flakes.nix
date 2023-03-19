let
  steps = import ./steps.nix;
  constants = import ./constants.nix;
  first = list: builtins.elemAt list 0;
in
with constants;
{
  name = "update-flakes";
  on = {
    schedule = [{ cron = "40 4 * * 0,2,4,6"; }];
    workflow_dispatch = null;
  };
  jobs = {
    update-flakes = {
      inherit (ubuntu) runs-on;
      steps = with steps; [
        maximimizeBuildSpaceStep
        checkoutStep
        cacheNixStore
        installNixActionStep
        importNixStoreCache
        setDefaultGitBranchStep
        cachixActionStep
        (buildNixOSConfigurationWithOutput (first nixos.hostnames) "/tmp/nixos_old")
        updateFlakeLockStep
        (buildHomeManagerConfigurations home-manager.linux.hostnames)
        (buildNixOSConfigurations nixos.hostnames)
        (buildNixOSConfigurationWithOutput (first nixos.hostnames) "/tmp/nixos_new")
        (diffNixOutputs "NixOS" "/tmp/nixos_old" "/tmp/nixos_new")
        (createPullRequestStep [ "NixOS" ])
        exportNixStoreCache
      ];
    };
  };
}

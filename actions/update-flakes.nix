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
        (buildNixOSConfigurations { hostnames = [ (first nixos.hostnames) ]; extraNixFlags = [ "-o /tmp/nixos_old" ]; })
        (buildHomeManagerConfigurations { hostnames = [ (first home-manager.linux.hostnames) ]; extraNixFlags = [ "-o /tmp/hm_old" ]; })
        updateFlakeLockStep
        (buildHomeManagerConfigurations { })
        (buildHomeManagerConfigurations { hostnames = [ (first home-manager.linux.hostnames) ]; extraNixFlags = [ "-o /tmp/hm_new" ]; })
        (buildNixOSConfigurations { })
        (buildNixOSConfigurations { hostnames = [ (first nixos.hostnames) ]; extraNixFlags = [ "-o /tmp/nixos_new" ]; })
        (diffNixOutputs "NixOS" "/tmp/nixos_old" "/tmp/nixos_new")
        (diffNixOutputs "Home-Manager" "/tmp/hm_old" "/tmp/hm_new")
        (createPullRequestStep [ "NixOS" "Home-Manager" ])
        exportNixStoreCache
      ];
    };
  };
}

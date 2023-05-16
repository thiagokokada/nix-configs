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
        installNixActionStep
        setDefaultGitBranchStep
        cachixActionStep
        # (buildNixOSConfigurations { hostnames = [ (first nixos.hostnames) ]; extraNixFlags = [ "-o /tmp/nixos_old" ]; })
        updateFlakeLockStep
        (buildHomeManagerConfigurations { })
        (buildNixOSConfigurations { })
        # (buildNixOSConfigurations { hostnames = [ (first nixos.hostnames) ]; extraNixFlags = [ "-o /tmp/nixos_new" ]; })
        # (diffNixOutputs "NixOS" "/tmp/nixos_old" "/tmp/nixos_new")
        (createPullRequestStep [ ])
      ];
    };
  };
}

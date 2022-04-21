let
  steps = import ./steps.nix;
  constants = import ./constants.nix;
in
{
  name = "update-flakes";
  on = [
    "workflow_dispatch"
    {
      schedule = [{ cron = "40 4 * * 0,2,4,6"; }];
    }
  ];
  jobs = {
    update-flakes = {
      inherit (constants.ubuntu) runs-on;
      steps = with steps; [
        maximimizeBuildSpaceStep
        checkoutStep
        installNixActionStep
        cachixActionStep
        updateFlakeLockStep
        setDefaultGitBranchStep
        (buildAllForSystemStep "linux")
        createPullRequestStep
      ];
    };
  };
}

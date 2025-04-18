let
  steps = import ./steps.nix;
  constants = import ./constants.nix;
in
with constants;
{
  name = "update-flakes";
  on = {
    schedule = [ { cron = "40 4 * * 0,2,4,6"; } ];
    workflow_dispatch = null;
  };
  jobs = {
    update-flakes-x86_64-linux = {
      inherit (ubuntu) runs-on;
      steps = with steps; [
        freeDiskSpaceStep
        checkoutStep
        (installNixActionStep { })
        cachixActionStep
        updateFlakeLockStep
        (buildHomeManagerConfigurations { inherit (home-manager.x86_64-linux) hostnames; })
        (buildNixOSConfigurations { inherit (nixos.x86_64-linux) hostnames; })
        createPullRequestStep
      ];
    };
  };
}

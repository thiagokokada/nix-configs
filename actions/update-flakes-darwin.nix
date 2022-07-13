let
  steps = import ./steps.nix;
  constants = import ./constants.nix;
in
{
  name = "update-flakes-darwin";
  on = {
    workflow_run = {
      workflows = [ "update-flakes" ];
      types = [ "completed" ];
    };
  };
  jobs = {
    update-flakes-macos = {
      inherit (constants.macos) runs-on;
      "if" = "\${{ github.event.workflow_run.conclusion == 'success' }}";
      steps = with steps; [
        checkoutStep
        installNixActionStep
        cachixActionStep
        setDefaultGitBranchStep
        (buildNixDarwinConfigs { })
        (buildHomeManagerConfigs { inherit (constants.HomeManager.macos) hostnames; })
      ];
    };
  };
}

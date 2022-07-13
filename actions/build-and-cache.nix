let
  steps = import ./steps.nix;
  constants = import ./constants.nix;
in
{
  name = "build-and-cache";
  on = [ "push" "workflow_dispatch" ];
  jobs = {
    build-linux = {
      inherit (constants.ubuntu) runs-on;
      steps = with steps; [
        maximimizeBuildSpaceStep
        checkoutStep
        installNixActionStep
        cachixActionStep
        setDefaultGitBranchStep
        checkNixStep
        validateFlakesStep
        (buildNixOSConfigs { })
        (buildHomeManagerConfigs { })
      ];
    };
    build-macos = {
      inherit (constants.macos) runs-on;
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

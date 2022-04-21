let
  steps = import ./steps.nix;
  constants = import ./constants.nix;
in
{
  name = "build-and-cache";
  on = [ "push" "workflow_dispatch" ];
  jobs = {
    build-0-linux = {
      inherit (constants.ubuntu) runs-on;
      steps = with steps; [
        maximimizeBuildSpaceStep
        checkoutStep
        installNixActionStep
        cachixActionStep
        setDefaultGitBranchStep
        checkNixStep
        validateFlakesStep
        (buildAllForSystemStep "linux")
      ];
    };
    build-1-macos = {
      inherit (constants.macos) runs-on;
      steps = with steps; [
        checkoutStep
        installNixActionStep
        cachixActionStep
        setDefaultGitBranchStep
        (buildAllForSystemStep "macos")
      ];
    };
  };
}

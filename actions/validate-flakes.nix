let
  steps = import ./steps.nix;
  constants = import ./constants.nix;
in
with constants;
{
  name = "validate-flakes";
  on = [ "push" "workflow_dispatch" ];
  jobs = {
    build-linux = {
      inherit (ubuntu) runs-on;
      steps = with steps; [
        checkoutStep
        installNixActionStep
        setupAarch64
        cachixActionStep
        setDefaultGitBranchStep
        checkNixStep
        validateFlakesStep
      ];
    };
  };
}

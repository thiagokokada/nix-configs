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
        (installNixActionStep {
          extraNixConfig = ''
            extra-platforms = aarch64-linux
          '';
        })
        setupAarch64
        cachixActionStep
        setDefaultGitBranchStep
        validateFlakesStep
      ];
    };
  };
}

let
  steps = import ./steps.nix;
  constants = import ./constants.nix;
in
with constants;
{
  name = "validate-flakes";
  on = [
    "push"
    "workflow_dispatch"
  ];
  jobs = {
    build-aarch64-linux = {
      inherit (ubuntu-arm) runs-on;
      steps =
        with steps;
        withSharedSteps [
          validateFlakesStep
        ];
    };

    build-x86_64-linux = {
      inherit (ubuntu) runs-on;
      steps =
        with steps;
        withSharedSteps [
          validateFlakesStep
        ];
    };
  };
}

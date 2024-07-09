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
    build-linux = {
      inherit (ubuntu) runs-on;
      steps = with steps; [
        checkoutStep
        (installUbuntuPackages [
          "binfmt-support"
          "qemu-user-static"
        ])
        (installNixActionStep { extraNixConfig = [ "extra-platforms = aarch64-linux" ]; })
        cachixActionStep
        validateFlakesStep
      ];
    };
  };
}

let
  steps = import ./steps.nix;
  constants = import ./constants.nix;
in
with constants;
{
  name = "build-and-cache";
  on = [ "push" "workflow_dispatch" ];
  jobs = {
    build-linux = {
      inherit (ubuntu) runs-on;
      steps = with steps; [
        freeDiskSpaceStep
        checkoutStep
        (installNixActionStep { })
        cachixActionStep
        setDefaultGitBranchStep
        (buildHomeManagerConfigurations { })
        (buildNixOSConfigurations { })
      ];
    };
    build-macos = {
      inherit (constants.macos) runs-on;
      steps = with steps; [
        checkoutStep
        (installNixActionStep { })
        cachixActionStep
        setDefaultGitBranchStep
        (buildHomeManagerConfigurations { inherit (home-manager.darwin) hostnames; })
      ];
    };
  };
}

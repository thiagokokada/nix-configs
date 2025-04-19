let
  steps = import ./steps.nix;
  constants = import ./constants.nix;
  utils = import ./utils.nix;
in
with constants;
with utils;
{
  name = "update-flakes-after";
  on = {
    workflow_run = {
      workflows = [ "update-flakes" ];
      types = [ "completed" ];
    };
    workflow_dispatch = null;
  };
  inherit (steps) concurrency;

  jobs = {
    update-flakes-aarch64-darwin = {
      inherit (macos) runs-on;
      "if" = escapeGhVar "github.event.workflow_run.conclusion == 'success'";
      steps =
        with steps;
        withSharedSteps [
          (buildHomeManagerConfigurations { inherit (home-manager.aarch64-darwin) hostnames; })
          (buildNixDarwinConfigurations { inherit (nix-darwin.aarch64-darwin) hostnames; })
        ];
    };

    update-flakes-aarch64-linux = {
      inherit (ubuntu-arm) runs-on;
      "if" = escapeGhVar "github.event.workflow_run.conclusion == 'success'";
      steps =
        with steps;
        withSharedSteps [
          freeDiskSpaceStep
          (buildHomeManagerConfigurations { inherit (home-manager.aarch64-linux) hostnames; })
          (buildNixOSConfigurations { inherit (nixos.aarch64-linux) hostnames; })
        ];
    };
  };
}

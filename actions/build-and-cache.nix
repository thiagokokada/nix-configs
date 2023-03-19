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
        maximimizeBuildSpaceStep
        checkoutStep
        cacheNixStore
        installNixActionStep
        importNixStoreCache
        cachixActionStep
        setDefaultGitBranchStep
        checkNixStep
        validateFlakesStep
        (buildHomeManagerConfigurations home-manager.linux.hostnames)
        (buildNixOSConfigurations nixos.hostnames)
        exportNixStoreCache
      ];
    };
    build-macos = {
      inherit (constants.macos) runs-on;
      steps = with steps; [
        checkoutStep
        cacheNixStore
        installNixActionStep
        importNixStoreCache
        cachixActionStep
        setDefaultGitBranchStep
        (buildHomeManagerConfigurations home-manager.darwin.hostnames)
        (buildNixDarwinConfigurations nix-darwin.hostnames)
        exportNixStoreCache
      ];
    };
  };
}

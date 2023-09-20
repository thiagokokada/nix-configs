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
        setupTailscale
        setupSshForRemoteBuilder
        (installNixActionStep {
          extraNixConfig = ''
            builders = ssh://zatsune-nixos-uk aarch64-linux
          '';
        })
        cachixActionStep
        setDefaultGitBranchStep
        (buildHomeManagerConfigurations { })
        (buildNixOSConfigurations { })
        (buildNixOSConfigurations { hostnames = [ "zatsune-nixos" ]; })
      ];
    };
    build-macos = {
      inherit (constants.macos) runs-on;
      steps = with steps; [
        checkoutStep
        (installNixActionStep { })
        cachixActionStep
        setDefaultGitBranchStep
        (buildHomeManagerConfigurations { hostnames = home-manager.darwin.hostnames; })
      ];
    };
  };
}

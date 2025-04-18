let
  steps = import ./steps.nix;
  constants = import ./constants.nix;
in
with constants;
{
  name = "build-and-cache";
  on = [
    "push"
    "workflow_dispatch"
  ];
  jobs = {
    build-x86_64-linux = {
      inherit (ubuntu) runs-on;
      steps = with steps; [
        freeDiskSpaceStep
        checkoutStep
        (installNixActionStep { })
        cachixActionStep
        (buildHomeManagerConfigurations { inherit (home-manager.x86_64-linux) hostnames; })
        (buildNixOSConfigurations { inherit (nixos.x86_64-linux) hostnames; })
      ];
    };
    build-aarch64-linux = {
      inherit (ubuntu-arm) runs-on;
      steps = with steps; [
        freeDiskSpaceStep
        checkoutStep
        (installNixActionStep { })
        cachixActionStep
        (buildHomeManagerConfigurations { inherit (home-manager.aarch64-linux) hostnames; })
      ];
    };
    build-aarch64-darwin = {
      inherit (macos) runs-on;
      steps = with steps; [
        checkoutStep
        (installNixActionStep { })
        cachixActionStep
        (buildHomeManagerConfigurations { inherit (home-manager.aarch64-darwin) hostnames; })
        (buildNixDarwinConfigurations { inherit (nix-darwin.aarch64-darwin) hostnames; })
      ];
    };
  };
}

{
  config,
  flake,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nix-darwin.home;
  inherit (config.nix-darwin.home) username;
in
{
  imports = [
    (flake.outputs.internal.sharedModules.helpers.mkHomeModule "nix-darwin")
    flake.inputs.home-manager.darwinModules.home-manager
  ];

  config = lib.mkIf cfg.enable {
    nix-darwin.home.extraModules = {
      home-manager.darwin.copyApps.enable = false;
      targets.darwin.linkApps.enable = false;
    };

    # https://github.com/nix-community/home-manager/issues/1341#issuecomment-3256894180
    system.build.applications = lib.mkForce (
      pkgs.buildEnv {
        name = "system-applications";
        pathsToLink = "/Applications";
        paths =
          config.environment.systemPackages
          ++ (lib.concatMap (x: x.home.packages) (lib.attrsets.attrValues config.home-manager.users));
      }
    );

    users.users.${username}.home = lib.mkDefault "/Users/${username}";
  };
}

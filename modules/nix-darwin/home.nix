{
  config,
  flake,
  lib,
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
      targets.darwin.linkApps.enable = false;
    };

    users.users.${username}.home = lib.mkDefault "/Users/${username}";
  };
}

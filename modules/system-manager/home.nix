{
  config,
  lib,
  pkgs,
  flake,
  ...
}:

let
  cfg = config.system-manager.home;
in
{
  imports = [
    (flake.outputs.internal.sharedModules.helpers.mkHomeModule "system-manager")
    flake.inputs.home-manager.nixosModules.home-manager
  ];

  config = lib.mkIf cfg.enable {
    system-manager.home.extraModules = {
      targets.genericLinux.enable = true;
    };
    users.groups.${cfg.username}.gid = lib.mkDefault 1000;
    users.users.${cfg.username} = {
      isNormalUser = true;
      uid = lib.mkDefault 1000;
      group = cfg.username;
      home = lib.mkDefault "/home/${cfg.username}";
      shell = pkgs.zsh;
      ignoreShellProgramCheck = true;
    };
  };
}

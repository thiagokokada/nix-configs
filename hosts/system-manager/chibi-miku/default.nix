{ config, ... }:

let
  cfg = config.system-manager.home;
in
{
  system-manager.allowAnyDistro = true;

  users.groups.${cfg.username}.gid = 10000;
  users.users.${cfg.username}.uid = 10000;
  system-manager.home.extraModules = [ ../../home-manager/chibi-miku ];
}

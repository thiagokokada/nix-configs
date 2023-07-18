{ lib, config, ... }:
let
  inherit (config.meta) username;
in
{
  imports = [ ./virtualisation.nix ];

  options.nixos.dev.enable = lib.mkDefaultOption "virtualisation config";

  config = lib.mkIf config.nixos.dev.enable {
    programs.adb.enable = true;

    # Added user to groups
    users.users.${username}.extraGroups = [ "adbusers" ];
  };
}

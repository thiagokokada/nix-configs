{ lib, config, ... }:
let
  inherit (config.meta) username;
in
{
  imports = [
    ./cross-compiling.nix
    ./virtualisation.nix
  ];

  options.nixos.dev.enable = lib.mkEnableOption "dev config";

  config = lib.mkIf config.nixos.dev.enable {
    programs.adb.enable = true;

    # Added user to groups
    users.users.${username}.extraGroups = [ "adbusers" ];
  };
}

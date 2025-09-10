{
  config,
  lib,
  ...
}:

let
  inherit (config.meta) username;
in
{
  imports = [
    ./ollama.nix
    ./virtualisation.nix
  ];

  options.nixos.dev.enable = lib.mkEnableOption "developer config" // {
    default = builtins.any (x: config.device.type == x) [
      "desktop"
      "laptop"
      "steam-machine"
    ];
  };

  config = lib.mkIf config.nixos.dev.enable {
    programs.adb.enable = true;

    # Added user to groups
    users.users.${username}.extraGroups = [ "adbusers" ];
  };
}

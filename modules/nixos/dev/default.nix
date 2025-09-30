{
  config,
  lib,
  ...
}:

let
  inherit (config.nixos.home) username;
in
{
  imports = [
    ./ollama.nix
    ./virtualisation
  ];

  options.nixos.dev.enable = lib.mkEnableOption "developer config" // {
    default = builtins.any (x: config.device.type == x) [
      "desktop"
      "laptop"
      "steam-machine"
    ];
  };

  config = lib.mkIf config.nixos.dev.enable {
    nixos.home.extraModules = {
      home-manager.dev.enable = true;
    };

    programs.adb.enable = true;

    # Added user to groups
    users.users.${username}.extraGroups = [ "adbusers" ];
  };
}

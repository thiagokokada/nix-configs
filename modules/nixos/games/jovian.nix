{
  lib,
  config,
  flake,
  ...
}:

let
  inherit (config.meta) username;
  cfg = config.nixos.games.jovian;
in
{
  imports = [
    flake.inputs.chaotic-nyx.nixosModules.default
    flake.inputs.jovian-nixos.nixosModules.default
  ];

  options.nixos.games.jovian = {
    enable = lib.mkEnableOption "Jovian-NixOS config" // {
      default = config.device.type == "steam-machine";
    };
  };

  config = lib.mkIf cfg.enable {
    chaotic = {
      mesa-git.enable = true;
    };

    jovian = {
      steam = {
        enable = true;
        autoStart = true;
        user = username;
        desktopSession = "plasma";
      };
      hardware.has.amd.gpu = config.nixos.games.gpu == "amd";
    };

    services.desktopManager.plasma6.enable = true;
  };
}

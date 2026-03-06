{ config, lib, ... }:

{
  imports = [
    ./android.nix
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
  };
}

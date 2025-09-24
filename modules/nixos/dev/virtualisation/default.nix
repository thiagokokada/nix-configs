{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (config.nixos.home) username;
  cfg = config.nixos.dev.virtualisation;
in
{
  imports = [ ./libvirt.nix ];

  options.nixos.dev.virtualisation = {
    enable = lib.mkEnableOption "virtualisation config" // {
      default = config.nixos.dev.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      distrobox
      podman-compose
    ];

    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
      };
    };

    users.users.${username}.extraGroups = [ "podman" ];
  };
}

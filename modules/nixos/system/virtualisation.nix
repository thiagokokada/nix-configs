{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (config.meta) username;
  cfg = config.nixos.system.virtualisation;
in
{
  options.nixos.system.virtualisation.enable = lib.mkEnableOption "virtualisation config" // {
    default = config.nixos.system.enable;
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      distrobox
      gnome-boxes
      podman-compose
    ];

    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
      };
      libvirtd.enable = true;
    };

    # Added user to groups
    users.users.${username}.extraGroups = [ "podman" ];
  };
}

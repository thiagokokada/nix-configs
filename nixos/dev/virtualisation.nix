{ pkgs, lib, config, ... }:
let
  inherit (config.meta) username;
in
{
  options.nixos.dev.virtualisation.enable = lib.mkEnableOption "virtualisation config" // {
    default = config.nixos.dev.enable;
  };

  config = lib.mkIf config.nixos.dev.virtualisation.enable {
    environment.systemPackages = with pkgs; [
      distrobox
      gnome.gnome-boxes
      podman-compose
    ];

    virtualisation = {
      podman = {
        enable = true;
        dockerCompat = true;
      };
      libvirtd.enable = true;
    };

    # Added user to groups
    users.users.${username}.extraGroups = [ "docker" ];
  };
}

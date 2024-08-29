{
  pkgs,
  lib,
  config,
  ...
}:

let
  inherit (config.mainUser) username;
in
{
  options.nixos.dev.virtualisation.enable = lib.mkEnableOption "virtualisation config" // {
    default = config.nixos.dev.enable;
  };

  config = lib.mkIf config.nixos.dev.virtualisation.enable {
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

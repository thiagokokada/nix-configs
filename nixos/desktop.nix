{ pkgs, config, ... }:

{
  imports = [ ./audio.nix ];

  environment.systemPackages = with pkgs; [ smartmontools ];

  services = {
    smartd = {
      enable = true;
      notifications.x11.enable = true;
    };
    gnome.gnome-keyring.enable = true;
  };
}

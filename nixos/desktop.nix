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

  xdg = {
    # For sway screensharing
    # https://nixos.wiki/wiki/Firefox
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-wlr
      ];
      gtkUsePortal = true;
    };
  };
}

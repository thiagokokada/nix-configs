{ pkgs, config, ... }:

{
  imports = [ ./audio.nix ];

  environment.systemPackages = with pkgs; [ smartmontools ];

  services = {
    # Enable Gnome Keyring
    gnome.gnome-keyring.enable = true;

    # Enable systemd-resolved
    resolved.enable = true;

    # Enable SMART monitoring
    smartd = {
      enable = true;
      notifications.x11.enable = true;
    };
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

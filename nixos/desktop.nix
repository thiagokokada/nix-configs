{ pkgs, config, ... }:

let
  inherit (config.meta) username;
in
{
  imports = [ ./audio.nix ];

  environment.systemPackages = with pkgs; [ smartmontools gnome.simple-scan ];

  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.hplipWithPlugin ];
  };

  users.users.${username} = { extraGroups = [ "sane" "lp" ]; };

  services = {
    printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };
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

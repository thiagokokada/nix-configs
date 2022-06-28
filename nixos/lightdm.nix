{ pkgs, ... }:

{
  services.xserver.displayManager = {
    defaultSession = "none+i3";

    lightdm = {
      enable = true;
      background = pkgs.nixos-artwork.wallpapers.dracula.gnomeFilePath;
      greeters = {
        gtk = {
          enable = true;
          clock-format = "%a %d/%m %H:%M:%S";
          iconTheme = {
            package = pkgs.arc-icon-theme;
            name = "Arc";
          };
          indicators = [ "~clock" "~session" "~power" ];
          theme = {
            package = pkgs.arc-theme;
            name = "Arc-Dark";
          };
        };
      };
    };
  };
}

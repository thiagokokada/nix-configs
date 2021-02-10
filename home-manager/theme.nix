{ config, pkgs, ... }:

{
  theme = {
    fonts = {
      gui = {
        package = pkgs.roboto;
        name = "Roboto";
      };
    };

    colors = builtins.fromJSON (builtins.readFile ./theme.json);
  };

  # Enable fonts in home.packages to be available to applications
  fonts.fontconfig.enable = true;

  home.packages = with pkgs;
    with config.theme.fonts; [
      font-awesome_5
      gui.package
      hack-font
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
    ];

  gtk = {
    enable = true;
    font = {
      package = pkgs.noto-fonts;
      name = "Noto Sans";
    };
    iconTheme = {
      package = pkgs.arc-icon-theme;
      name = "Arc";
    };
    theme = with config.theme.gtk; {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
  };
}

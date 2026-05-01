{ lib, ... }:

{
  home.stateVersion = "26.05";

  targets.genericLinux.nixGL = {
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
  };

  dconf.settings = with lib.hm.gvariant; {
    "org.gnome.mutter" = {
      "experimental-features" = mkArray type.string [
        # Enable fractional scaling
        "scale-monitor-buffer"
        # Enable xwayland native scaling
        "xwayland-native-scaling"
      ];
    };
  };

  home-manager = {
    cli = {
      icons.enable = true;
      git.gui.enable = true;
    };
    desktop = {
      mpv.enable = true;
      fonts.fontconfig.enable = true;
    };
    dev = {
      enable = true;
      nix.languageServer = "nil";
    };
  };
}

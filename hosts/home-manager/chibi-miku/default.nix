{ ... }:

{
  home.stateVersion = "26.05";

  targets.genericLinux.enable = true;

  home-manager = {
    cli = {
      icons.enable = true;
      git.gui.enable = true;
    };
    desktop = {
      fonts.fontconfig.enable = true;
      ghostty.enable = true;
      mpv.enable = true;
      nixgl.enable = false;
    };
    dev = {
      enable = true;
      nix.languageServer = "nil";
    };
  };
}

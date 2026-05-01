{
  home.stateVersion = "26.05";

  targets.genericLinux.nixGL = {
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
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

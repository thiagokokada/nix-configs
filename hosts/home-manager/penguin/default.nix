{
  home.stateVersion = "24.05";

  targets.genericLinux.nixGL = {
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
  };

  home-manager = {
    crostini.enable = true;
    cli.git.gui.enable = true;
    desktop.mpv.enable = true;
    dev.enable = true;
  };
}

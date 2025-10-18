{
  home = rec {
    username = "deck";
    homeDirectory = "/home/${username}";
    stateVersion = "25.05";
  };

  nixGL = {
    defaultWrapper = "mesa";
    installScripts = [ "mesa" ];
  };

  home-manager = {
    cli.git.gui.enable = true;
    dev.enable = true;
  };

  targets.genericLinux.enable = true;
}

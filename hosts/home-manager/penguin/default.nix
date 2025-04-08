{
  home = rec {
    username = "thiagoko";
    homeDirectory = "/home/${username}";
    stateVersion = "24.05";
  };

  home-manager.crostini.enable = true;
}

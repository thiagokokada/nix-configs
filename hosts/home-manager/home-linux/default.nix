{
  home = rec {
    username = "thiagoko";
    homeDirectory = "/home/${username}";
    stateVersion = "24.05";
  };

  targets.genericLinux.enable = true;
}

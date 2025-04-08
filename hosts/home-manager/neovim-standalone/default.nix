{
  home = {
    username = "neovim-standalone";
    homeDirectory = "/tmp";
    stateVersion = "24.05";
  };

  home-manager = {
    dev.nix.enable = true;
    editor.neovim = {
      icons.enable = false;
      lsp.enable = true;
      treeSitter.enable = true;
    };
  };
}

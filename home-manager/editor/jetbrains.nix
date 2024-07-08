{
  config,
  lib,
  pkgs,
  flake,
  ...
}:

{
  # TODO: add declarative IDE setup
  # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/jetbrains/readme.md
  options.home-manager.editor.jetbrains.enable = lib.mkEnableOption "Jetbrains IDEs config";

  config = lib.mkIf config.home-manager.editor.jetbrains.enable {
    home.file = {
      ".intellimacs".source = flake.inputs.intellimacs;
      ".ideavimrc".source =
        pkgs.writeText "ideavimrc" # vim
          ''
            " Enable Intellimacs
            source ~/.intellimacs/spacemacs.vim

            " Enable other Intellimacs modules
            source ~/.intellimacs/extra.vim
            source ~/.intellimacs/major.vim
            source ~/.intellimacs/hybrid.vim

            " Enable which-key plugin
            source ~/.intellimacs/which-key.vim

            " Comma for major mode
            nmap , <leader>m
            vmap , <leader>m

            " Plugins
            Plug 'easymotion/vim-easymotion'
            Plug 'preservim/nerdtree'
            Plug 'tpope/vim-surround'
            Plug 'tpope/vim-commentary'
            Plug 'michaeljsmith/vim-indent-object'

            " Vinegar
            nmap - :NERDTreeToggle<CR>

            " Enable ideajoin
            " https://github.com/JetBrains/ideavim/blob/master/doc/ideajoin-examples.md
            set ideajoin
          '';
    };
  };
}

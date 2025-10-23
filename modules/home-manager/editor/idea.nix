{
  config,
  lib,
  pkgs,
  flake,
  ...
}:

let
  cfg = config.home-manager.editor.idea;
in
{
  options.home-manager.editor.idea = {
    enable = lib.mkEnableOption "IntelliJ config";
    packages = lib.mkOption {
      description = "Packages to add from IntelliJ.";
      default = with pkgs.jetbrains; [ idea-community ];
      type = with lib.types; nullOr (listOf package);
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      file = {
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
              source ~/.intellimacs/which-key.vim

              " Comma for major mode
              nmap , <leader>m
              vmap , <leader>m

              " Plugins
              set commentary
              set easymotion
              set highlightedyank
              set ideajoin
              set mini-ai
              set NERDTree
              set surround
              set sneak

              " vim-highlightedyank
              let g:highlightedyank_highlight_duration = "300"

              " Vinegar-like
              nnoremap - :NERDTreeToggle<CR>

              " Unsets the 'last search pattern'
              nnoremap <C-g> :noh<CR>

              " HACK: Workaround IDEA "eating" the character under cursor
              " For some reason it is only happening in "
              nnoremap vi" :normal! vi"<CR>
              nnoremap va" :normal! va"<CR>
            '';
      };

      packages = lib.mkIf (cfg.packages != null) cfg.packages;
    };
  };
}

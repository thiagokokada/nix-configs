{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [ universal-ctags unstable.fzf git ];

    configure = {
      customRC = ''
        "" General config
        " remap leader
        let g:mapleader = "\<Space>"
        let g:maplocalleader = ','

        " enable/disable paste mode
        set pastetoggle=<F4>

        " show line number
        set number

        " live substitutions as you type
        set inccommand=nosplit

        " copy and paste
        set clipboard+=unnamedplus

        " show vertical column
        set colorcolumn=81,121

        " managed by lightline
        set noshowmode

        " turn on omnicomplete
        set omnifunc=syntaxcomplete#Complete

        " unsets the 'last search pattern'
        nnoremap <C-g> :noh<CR><CR>

        " removes trailing spaces
        nnoremap <Leader>w :StripWhitespace<CR>

        " make Esc enter Normal mode in term
        tnoremap <Esc> <C-\><C-n>
        tnoremap <M-[> <Esc>
        tnoremap <C-v><Esc> <Esc>

        " window movement mappings
        tnoremap <C-h> <c-\><c-n><c-w>h
        tnoremap <C-j> <c-\><c-n><c-w>j
        tnoremap <C-k> <c-\><c-n><c-w>k
        tnoremap <C-l> <c-\><c-n><c-w>l
        inoremap <C-h> <Esc><c-w>h
        inoremap <C-j> <Esc><c-w>j
        inoremap <C-k> <Esc><c-w>k
        inoremap <C-l> <Esc><c-w>l
        vnoremap <C-h> <Esc><c-w>h
        vnoremap <C-j> <Esc><c-w>j
        vnoremap <C-k> <Esc><c-w>k
        vnoremap <C-l> <Esc><c-w>l
        nnoremap <C-h> <c-w>h
        nnoremap <C-j> <c-w>j
        nnoremap <C-k> <c-w>k
        nnoremap <C-l> <c-w>l

        " completion
        noremap! <expr> <C-Space> "<C-x><C-o>"
        noremap! <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
        noremap! <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"

        "" fzf
        let g:fzf_layout = { 'down': '40%' }
        function! RipgrepFzf(query, fullscreen)
          let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
          let initial_command = printf(command_fmt, shellescape(a:query))
          let reload_command = printf(command_fmt, '{q}')
          let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
          call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
        endfunction

        command! -bang -nargs=? -complete=dir Files
              \ call fzf#vim#files(<q-args>, fzf#vim#with_preview(), <bang>0)
        command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

        nnoremap <Leader><Leader> :GitFiles --cached --others --exclude-standard<CR>
        nnoremap <Leader>b :Buffers<CR>
        nnoremap <Leader>/ :RG<space>
        nnoremap <silent> <Leader>* :Rg <C-R><C-W><CR>
        vnoremap <silent> <Leader>* y:Rg <C-R>"<CR>
        " undo terminal mappings just for fzf window
        au FileType fzf,Rg tnoremap <buffer> <C-h> <Left>
        au FileType fzf,Rg tnoremap <buffer> <C-j> <Down>
        au FileType fzf,Rg tnoremap <buffer> <C-k> <Up>
        au FileType fzf,Rg tnoremap <buffer> <C-l> <Right>
        au FileType fzf,Rg tnoremap <buffer> <Esc> <C-g>

        " selecting mappings
        nmap <Leader><Tab> <Plug>(fzf-maps-n)
        xmap <Leader><Tab> <Plug>(fzf-maps-x)
        omap <Leader><Tab> <Plug>(fzf-maps-o)

        "" onedark
        if (has("termguicolors"))
          set termguicolors
        endif
        packadd! onedark-vim
        colorscheme onedark

        "" lightline
        let g:lightline = {
            \ 'colorscheme': 'onedark',
            \ 'active': {
            \   'left': [ [ 'mode', 'paste' ],
            \             [ 'filename', 'readonly', 'modified' ],
            \           ],
            \   'right': [
            \             [ 'trailing' ],
            \             [ 'percent' ],
            \             [ 'lineinfo' ],
            \             [ 'fileformat', 'fileencoding' ],
            \             [ 'gutentags'],
            \            ],
            \ },
            \ 'component_expand': {
            \   'trailing': 'lightline#trailing_whitespace#component',
            \ },
            \ 'component_function': {
            \   'gitbranch': 'fugitive#head',
            \   'gutentags': 'gutentags#statusline',
            \   'trailing': 'lightline#trailing_whitespace#component'
            \ },
            \ 'component_type': {
            \   'trailing': 'error'
            \ },
            \ 'separator': {
            \   'left': '',
            \   'right': '',
            \ },
            \ 'subseparator': {
            \   'left': '',
            \   'right': '',
            \ },
            \ }

        "" rainbow
        let g:rainbow_active = 1

        "" undotree
        if !isdirectory($HOME . "/.config/nvim/undotree")
            call mkdir($HOME . "/.config/nvim/undotree", "p", 0755)
        endif

        nnoremap <Leader>u :UndotreeToggle<CR>
        set undofile
        set undodir=~/.config/nvim/undotree
        let undotree_WindowLayout = 3

        "" gutentags
        let g:gutentags_cache_dir="~/.config/nvim/gutentags"
        let g:gutentags_file_list_command = {
            \ 'markers': {
            \   '.git': 'git ls-files',
            \   '.hg': 'hg files',
            \ },
            \ }

        augroup UpdateLightlineForGutentags
            autocmd!
            autocmd User GutentagsUpdating call lightline#update()
            autocmd User GutentagsUpdated call lightline#update()
        augroup END

        "" endwise
        let g:endwise_no_mappings = v:true
        imap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR><Plug>DiscretionaryEnd"
        imap <script> <C-X><CR> <CR><SID>AlwaysEnd

        "" sneak
        let g:sneak#label = 1
        map f <Plug>Sneak_f
        map F <Plug>Sneak_F
        map t <Plug>Sneak_t
        map T <Plug>Sneak_T
      '';

      # To install non-packaged plugins, use
      # pkgs.vimUtils.buildVimPluginFrom2Nix { }
      packages.myVimPackage = with pkgs.unstable.vimPlugins; {
        opt = [ onedark-vim ];

        start = [
          auto-pairs
          fzf-vim
          gitgutter
          lightline-vim
          rainbow
          undotree
          vim-automkdir
          vim-autoswap
          vim-better-whitespace
          vim-commentary
          vim-endwise
          vim-fugitive
          vim-gutentags
          vim-lastplace
          vim-polyglot
          vim-repeat
          vim-sleuth
          vim-sneak
          vim-surround
          vim-vinegar
        ];
      };
    };
  };
}

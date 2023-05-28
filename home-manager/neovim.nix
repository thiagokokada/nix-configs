{ pkgs, ... }:

{
  home.packages = with pkgs; [ universal-ctags ripgrep ];

  programs.neovim = {
    enable = true;

    withRuby = false;
    withNodeJs = false;
    withPython3 = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraConfig = ''
      "" General config
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

      " folding
      set foldmethod=expr
      set foldexpr=nvim_treesitter#foldexpr()
      set nofoldenable " disable folding at startup
    '';

    # To install non-packaged plugins, use
    # pkgs.vimUtils.buildVimPluginFrom2Nix { }
    plugins = with pkgs; with vimPlugins; [
      {
        # FIXME: dummy plugin since there is no way currently to set a config
        # before the plugins are initialized
        # See: https://github.com/nix-community/home-manager/pull/2391
        plugin = (pkgs.writeText "init-pre" "");
        config = ''
          " remap leader
          let g:mapleader = "\<Space>"
          let g:maplocalleader = ','
        '';
      }
      {
        plugin = nvim-autopairs;
        config = ''
          lua << EOF
          require("nvim-autopairs").setup {}
          EOF
        '';
      }
      {
        plugin = nvim-lastplace;
        config = ''
          lua << EOF
          require('nvim-lastplace').setup {
            lastplace_ignore_buftype = {"quickfix", "nofile", "help"},
            lastplace_ignore_filetype = {"gitcommit", "gitrebase", "svn", "hgcommit"},
          }
          EOF
        '';
      }
      {
        plugin = onedark-vim;
        config = ''
          if (has("termguicolors"))
            set termguicolors
          endif
          colorscheme onedark
        '';
      }
      {
        plugin = lightline-vim;
        config = ''
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
              \            ],
              \ },
              \ 'component_expand': {
              \   'trailing': 'lightline#trailing_whitespace#component',
              \ },
              \ 'component_function': {
              \   'gitbranch': 'fugitive#head',
              \   'trailing': 'lightline#trailing_whitespace#component'
              \ },
              \ 'component_type': {
              \   'trailing': 'error'
              \ },
              \ }
        '';
      }
      {
        plugin = undotree;
        config = ''
          if !isdirectory($HOME . "/.config/nvim/undotree")
              call mkdir($HOME . "/.config/nvim/undotree", "p", 0755)
          endif

          nnoremap <Leader>u :UndotreeToggle<CR>
          set undofile
          set undodir=~/.config/nvim/undotree
          let undotree_WindowLayout = 3
        '';
      }
      {
        plugin = vim-endwise;
        config = ''
          let g:endwise_no_mappings = v:true
          imap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR><Plug>DiscretionaryEnd"
          imap <script> <C-X><CR> <CR><SID>AlwaysEnd
        '';
      }
      {
        plugin = vim-sneak;
        config = ''
          let g:sneak#label = 1
          map f <Plug>Sneak_f
          map F <Plug>Sneak_F
          map t <Plug>Sneak_t
          map T <Plug>Sneak_T
        '';
      }
      {
        plugin = nvim-treesitter.withAllGrammars;
        config = ''
          lua << EOF
          require('nvim-treesitter.configs').setup {
            highlight = {
              enable = true,
            },
            incremental_selection = {
              enable = true,
              keymaps = {
                init_selection = "gnn", -- set to `false` to disable one of the mappings
                node_incremental = "grn",
                scope_incremental = "grc",
                node_decremental = "grm",
              },
            },
            autotag = {
              enable = true,
            },
            context_commentstring = {
              enable = true,
            },
            indent = {
              enable = true,
            },
            endwise = {
              enable = true,
            },
          }
          EOF
        '';
      }
      {
        plugin = vim-polyglot;
        config = ''
          " use a simpler and faster regex to parse CSV
          " does not work with CSVs where the delimiter is quoted inside the field
          " let g:csv_strict_columns = 1
          " disabled CSV concealing (e.g.: `,` -> `|`), also faster
          let g:csv_no_conceal = 1
        '';
      }
      {
        plugin = telescope-nvim;
        config = ''
          lua << EOF
          local actions = require('telescope.actions')
          require('telescope').setup {
            defaults = {
              -- Default configuration for telescope goes here:
              -- config_key = value,
              mappings = {
                i = {
                  ["<C-j>"] = actions.move_selection_next,
                  ["<C-k>"] = actions.move_selection_previous,
                },
              },
              -- ivy-like theme
              layout_strategy = 'bottom_pane',
              layout_config = {
                height = 0.4,
              },
              border = true,
              sorting_strategy = "ascending",
            },
            extensions = {
              fzf = {
                fuzzy = true,                    -- false will only do exact matching
                override_generic_sorter = true,  -- override the generic sorter
                override_file_sorter = true,     -- override the file sorter
                case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
              },
            },
          }
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<leader><leader>', builtin.find_files, { noremap = true })
          vim.keymap.set('n', '<leader>/', builtin.live_grep, { noremap = true })
          vim.keymap.set('n', '<leader>*', builtin.grep_string, { noremap = true })
          vim.keymap.set('v', '<leader>*', builtin.grep_string, { noremap = true })
          EOF
        '';
      }
      {
        plugin = lir-nvim;
        config = ''
          lua << EOF
          local actions = require('lir.actions')
          local mark_actions = require('lir.mark.actions')
          local clipboard_actions = require('lir.clipboard.actions')

          require('lir').setup {
            show_hidden_files = false,
            ignore = {},
            devicons = {
              enable = true,
              highlight_dirname = false
            },
            mappings = {
              ['<Enter>'] = actions.edit,
              ['<C-s>']   = actions.split,
              ['<C-v>']   = actions.vsplit,
              ['<C-t>']   = actions.tabedit,

              ['-']       = actions.up,
              ['q']       = actions.quit,

              ['K']       = actions.mkdir,
              ['N']       = actions.newfile,
              ['R']       = actions.rename,
              ['@']       = actions.cd,
              ['Y']       = actions.yank_path,
              ['.']       = actions.toggle_show_hidden,
              ['D']       = actions.delete,

              ['J'] = function()
                mark_actions.toggle_mark()
                vim.cmd('normal! j')
              end,
              ['C'] = clipboard_actions.copy,
              ['X'] = clipboard_actions.cut,
              ['P'] = clipboard_actions.paste,
            },
          }

          -- vinegar
          vim.api.nvim_set_keymap('n', '-', [[<Cmd>execute 'e ' .. expand('%:p:h')<CR>]], { noremap = true })
          EOF
        '';
      }
      (vimUtils.buildVimPlugin {
        name = "AdvancedSorters";
        src = fetchFromGitHub {
          owner = "inkarkat";
          repo = "vim-AdvancedSorters";
          rev = "1.30";
          sha256 = "sha256-dpVfd0xaf9SAXxy0h6C8q4e7s7WTY8zz+JVDr4zVsQE=";
        };
      })
      (vimUtils.buildVimPlugin rec {
        name = "lightline-trailing-whitespace";
        src = fetchFromGitHub {
          owner = "maximbaz";
          repo = name;
          rev = "869ba29edae15b44061cb4e8d964d66bcb2421ff";
          sha256 = "sha256-g6Rmb9LTBw6hIEWBvcM6KYAv3ChEzC7gcy0OH95aTXM=";
        };
      })
      gitgutter
      nvim-treesitter-endwise
      nvim-ts-autotag
      nvim-ts-context-commentstring
      nvim-web-devicons
      telescope-fzf-native-nvim
      vim-automkdir
      vim-autoswap
      vim-better-whitespace
      vim-commentary
      vim-fugitive
      vim-repeat
      vim-sleuth
      vim-surround
    ];
  };

  programs.zsh.sessionVariables = {
    EDITOR = "nvim";
  };
}

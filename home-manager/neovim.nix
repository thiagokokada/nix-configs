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

      " turn on omnicomplete
      set omnifunc=syntaxcomplete#Complete

      " unsets the 'last search pattern'
      nnoremap <C-g> :noh<CR><CR>

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

      " threat words with dash as a word
      set iskeyword+=-

      " completion
      set completeopt=menu
      inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
      inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"
      inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"

      " disable "How to disable mouse" menu
      aunmenu PopUp.How-to\ disable\ mouse
      aunmenu PopUp.-1-

      " disable netrw
      let g:loaded_netrw       = 1
      let g:loaded_netrwPlugin = 1
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

          lua << EOF
          -- bytecompile lua modules
          vim.loader.enable()
          EOF
        '';
      }
      {
        plugin = comment-nvim;
        config = ''
          lua << EOF
          require('Comment').setup {}
          EOF
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
        plugin = onedark-vim;
        config = ''
          if (has("termguicolors"))
            set termguicolors
          endif
          colorscheme onedark
        '';
      }
      {
        plugin = lualine-nvim;
        # TODO: add support for trailing whitespace
        config = ''
          lua << EOF
          require('lualine').setup {}
          EOF
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
        plugin = project-nvim;
        config = ''
          lua << EOF
          require("project_nvim").setup {}
          vim.api.nvim_set_keymap(
            'n',
            '<Leader>p',
            ":Telescope projects<CR>",
            { noremap = true }
          )
          EOF
        '';
      }
      {
        plugin = nvim-lspconfig;
        config = ''
          lua << EOF
          -- Setup language servers.
          -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
          local lspconfig = require('lspconfig')
          lspconfig.bashls.setup {}
          lspconfig.clojure_lsp.setup {}
          lspconfig.pyright.setup {}
          lspconfig.nil_ls.setup {
            settings = {
              ['nil'] = {
                formatting = {
                  command = { "nixpkgs-fmt" },
                },
              },
            },
          }

          local builtin = require('telescope.builtin')
          -- Use LspAttach autocommand to only map the following keys
          -- after the language server attaches to the current buffer
          vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', {}),
            callback = function(ev)
              -- Enable completion triggered by <c-x><c-o>
              vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

              -- Buffer local mappings.
              -- See `:help vim.lsp.*` for documentation on any of the below functions
              local opts = { buffer = ev.buf }
              vim.keymap.set('n', 'gD', builtin.lsp_references, opts)
              vim.keymap.set('n', 'gd', builtin.lsp_definitions, opts)
              vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
              vim.keymap.set('n', 'gi', builtin.lsp_implementations, opts)
              vim.keymap.set('n', '<Leader>s', vim.lsp.buf.signature_help, opts)
              vim.keymap.set('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, opts)
              vim.keymap.set('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
              vim.keymap.set('n', '<Leader>wl', function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
              end, opts)
              vim.keymap.set('n', '<Leader>D', builtin.lsp_type_definitions, opts)
              vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)
              vim.keymap.set({ 'n', 'v' }, '<Leader>ca', vim.lsp.buf.code_action, opts)
              vim.keymap.set('n', '<Leader>f', function()
                vim.lsp.buf.format { async = true }
              end, opts)
              vim.keymap.set('n', '<Leader>e', builtin.diagnostics, opts)
            end,
          })
          EOF
        '';
      }
      {
        plugin = nvim-treesitter.withAllGrammars;
        config = ''
          " folding
          " disabled for now since this is slowing down neovim considerably
          " set foldmethod=expr
          " set foldexpr=nvim_treesitter#foldexpr()
          " set nofoldenable " disable folding at startup
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
            indent = {
              enable = true,
            },
            autotag = {
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
        plugin = telescope-nvim;
        config = ''
          lua << EOF
          local actions = require('telescope.actions')
          local telescope = require('telescope')
          telescope.setup {
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
              preview = {
                -- set timeout low enough that it never feels too slow
                timeout = 50,
              },
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
          telescope.load_extension('fzf')
          telescope.load_extension('projects')
          local builtin = require('telescope.builtin')
          vim.keymap.set('n', '<Leader><Leader>', builtin.find_files, { noremap = true })
          vim.keymap.set('n', '<Leader>/', builtin.live_grep, { noremap = true })
          vim.keymap.set({'n', 'v'}, '<Leader>*', builtin.grep_string, { noremap = true })
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
              enable = ${if stdenv.isDarwin then "false" else "true"},
              highlight_dirname = false
            },
            mappings = {
              ['<Enter>'] = actions.edit,
              ['<C-s>'] = actions.split,
              ['<C-v>'] = actions.vsplit,
              ['<C-t>'] = actions.tabedit,

              ['-'] = actions.up,
              ['q'] = actions.quit,

              ['K'] = actions.mkdir,
              ['N'] = actions.newfile,
              ['R'] = actions.rename,
              ['@'] = actions.cd,
              ['Y'] = actions.yank_path,
              ['.'] = actions.toggle_show_hidden,
              ['D'] = actions.delete,

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
      {
        plugin = whitespace-nvim;
        config = ''
          lua << EOF
          require('whitespace-nvim').setup {
            -- configuration options and their defaults

            -- `highlight` configures which highlight is used to display
            -- trailing whitespace
            highlight = 'DiffDelete',

            -- `ignored_filetypes` configures which filetypes to ignore when
            -- displaying trailing whitespace
            ignored_filetypes = { 'TelescopePrompt', 'Trouble', 'help' },

            -- `ignore_terminal` configures whether to ignore terminal buffers
            ignore_terminal = true,
          }

          -- remove trailing whitespace with a keybinding
          vim.keymap.set('n', '<Leader>w', require('whitespace-nvim').trim)
          EOF
        '';
      }
      gitgutter
      mkdir-nvim
      nvim-ts-autotag
      telescope-fzf-native-nvim
      vim-advanced-sorters
      vim-endwise
      vim-fugitive
      vim-lastplace
      vim-repeat
      vim-sleuth
      vim-surround
    ] ++
    lib.optionals (!pkgs.stdenv.isDarwin) [
      # give [?] icons in macOS
      nvim-web-devicons
    ];
  };

  programs.zsh.sessionVariables = {
    EDITOR = "nvim";
  };
}

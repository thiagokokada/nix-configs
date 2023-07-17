{ pkgs, ... }:

{
  home.packages = with pkgs; [ ripgrep ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;

    withRuby = false;
    withNodeJs = false;
    withPython3 = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraConfig = ''
      "" General config
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
      inoremap <C-Space> <C-x><C-o>
      " commandline
      cnoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-j>"
      cnoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>"
      cnoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"

      " disable "How to disable mouse" menu
      aunmenu PopUp.How-to\ disable\ mouse
      aunmenu PopUp.-1-

      " syntax highlight flake.lock files as json
      autocmd BufNewFile,BufRead flake.lock set filetype=json

      " keep comment leader when 'o' or 'O' is used in Normal mode
      autocmd FileType * set formatoptions+=o
    '';

    # To install non-packaged plugins, use
    # pkgs.vimUtils.buildVimPluginFrom2Nix { }
    plugins = with pkgs; with vimPlugins; [
      {
        # FIXME: dummy plugin since there is no way currently to set a config
        # before the plugins are initialized
        # See: https://github.com/nix-community/home-manager/pull/2391
        plugin = (pkgs.writeText "00-init-pre" "");
        config = ''
          " remap leader
          let g:mapleader = "\<Space>"
          let g:maplocalleader = ','

          lua << EOF
          -- bytecompile lua modules
          vim.loader.enable()

          -- load .exrc, .nvimrc and .nvim.lua local files
          vim.o.exrc = true
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
        plugin = gitsigns-nvim;
        config = ''
          lua << EOF
          require('gitsigns').setup {}
          EOF
        '';
      }
      {
        plugin = lir-nvim;
        config = ''
          " disable netrw
          let g:loaded_netrw       = 1
          let g:loaded_netrwPlugin = 1

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
          vim.api.nvim_set_keymap(
            'n',
            '-',
            [[<Cmd>execute 'e ' .. expand('%:p:h')<CR>]],
            { noremap = true, desc = "Files" }
          )
          EOF
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
        plugin = nvim-autopairs;
        config = ''
          lua << EOF
          require("nvim-autopairs").setup {}
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

          -- Global mappings.
          -- See `:help vim.diagnostic.*` for documentation on any of the below functions
          vim.keymap.set('n', '<space>ld', builtin.diagnostics, { desc = "LSP diagnostics" })

          -- Use LspAttach autocommand to only map the following keys
          -- after the language server attaches to the current buffer
          vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('UserLspConfig', {}),
            callback = function(ev)
              -- Enable completion triggered by <c-x><c-o>
              vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

              -- Buffer local mappings.
              -- See `:help vim.lsp.*` for documentation on any of the below functions
              vim.keymap.set('n', 'gD', builtin.lsp_references, { buffer = ev.buf, desc = "LSP references" })
              vim.keymap.set('n', 'gd', builtin.lsp_definitions, { buffer = ev.buf, desc = "LSP definitions" })
              vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = ev.buf, desc = "LSP symbol under" })
              vim.keymap.set('n', 'gi', builtin.lsp_implementations, { buffer = ev.buf, desc = "LSP implementations" })
              vim.keymap.set('n', '<Leader>ls', vim.lsp.buf.signature_help, { buffer = ev.buf, desc = "LSP signature help" })
              vim.keymap.set('n', '<Leader>lwa', vim.lsp.buf.add_workspace_folder, { buffer = ev.buf, desc = "LSP add workspace" })
              vim.keymap.set('n', '<Leader>lwr', vim.lsp.buf.remove_workspace_folder, { buffer = ev.buf, desc = "LSP remove workspace" })
              vim.keymap.set('n', '<Leader>lwl', function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
              end, { buffer = ev.buf, desc = "LSP list workspaces" })
              vim.keymap.set('n', '<Leader>lt', builtin.lsp_type_definitions, { buffer = ev.buf, desc = "LSP type definitions" })
              vim.keymap.set('n', '<Leader>lr', vim.lsp.buf.rename, { buffer = ev.buf, desc = "LSP rename" })
              vim.keymap.set({ 'n', 'v' }, '<Leader>la', vim.lsp.buf.code_action, { buffer = ev.buf, desc = "LSP code action" })
              vim.keymap.set('n', '<Leader>f', function()
                vim.lsp.buf.format { async = true }
              end, { buffer = ev.buf, desc = "LSP format" })
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
              -- disable slow treesitter highlight for large files
              disable = function(lang, buf)
                  local max_filesize = 100 * 1024 -- 100 KB
                  local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                  if ok and stats and stats.size > max_filesize then
                      return true
                  end
              end,
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
        plugin = onedarkpro-nvim;
        config = ''
          lua << EOF
          vim.cmd("colorscheme onedark")
          EOF
        '';
      }
      {
        plugin = openingh-nvim;
        config = ''
          lua << EOF
          -- for repository page
          vim.keymap.set({'n', 'v'}, '<Leader>gr', ":OpenInGHRepo <CR>", { silent = true, noremap = true, desc = "Open in GitHub repo" })

          -- for current file page
          vim.keymap.set('n', '<Leader>gf', ":OpenInGHFile <CR>", { silent = true, noremap = true, desc = "Open in GitHub file" })
          vim.keymap.set('v', '<Leader>gf', ":OpenInGHFileLines <CR>", { silent = true, noremap = true, desc = "Open in GitHub lines" })
          EOF
        '';
      }
      {
        plugin = other-nvim;
        config = ''
          lua << EOF
          require("other-nvim").setup {
            mappings = {
              "livewire",
              "angular",
              "laravel",
              "rails",
              "golang",
            },
          }

          vim.keymap.set("n", "<leader>aa", "<cmd>:Other<CR>", { noremap = true, silent = true, desc = "Other" })
          vim.keymap.set("n", "<leader>as", "<cmd>:OtherSplit<CR>", { noremap = true, silent = true, desc = "Other h-split" })
          vim.keymap.set("n", "<leader>av", "<cmd>:OtherVSplit<CR>", { noremap = true, silent = true, desc = "Other v-split" })
          vim.keymap.set("n", "<leader>ac", "<cmd>:OtherClear<CR>", { noremap = true, silent = true, desc = "Other clear" })

          -- Context specific bindings
          vim.keymap.set("n", "<leader>at", "<cmd>:Other test<CR>", { noremap = true, silent = true, desc = "Other test" })
          EOF
        '';
      }
      {
        plugin = project-nvim;
        config = ''
          lua << EOF
          require('project_nvim').setup {}
          vim.keymap.set(
            'n',
            '<Leader>p',
            ":Telescope projects<CR>",
            { noremap = true, desc = "Projects" }
          )
          EOF
        '';
      }
      {
        plugin = remember-nvim;
        config = ''
          lua << EOF
          require('remember').setup {}
          EOF
        '';
      }
      {
        plugin = undotree;
        config = ''
          if !isdirectory($HOME . "/.config/nvim/undotree")
              call mkdir($HOME . "/.config/nvim/undotree", "p", 0755)
          endif

          set undofile
          set undodir=~/.config/nvim/undotree
          let undotree_WindowLayout = 3
          lua << EOF
          vim.keymap.set('n', '<Leader>u', ':UndotreeToggle<CR>', { noremap = true, desc = "Undotree toggle" })
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
          vim.keymap.set('n', '<Leader><Leader>', builtin.find_files, { noremap = true, desc = "Find files" })
          vim.keymap.set('n', '<Leader>/', builtin.live_grep, { noremap = true, desc = "Live grep" })
          vim.keymap.set({'n', 'v'}, '<Leader>*', builtin.grep_string, { noremap = true, desc = "Grep string" })
          EOF
        '';
      }
      {
        plugin = which-key-nvim;
        config = ''
          lua << EOF
          vim.o.timeout = true
          vim.o.timeoutlen = 300
          require("which-key").setup {}
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
          vim.keymap.set(
            'n',
            '<Leader>w',
            require('whitespace-nvim').trim,
            { noremap = true, desc = "Trim whitespace" }
          )
          EOF
        '';
      }
      {
        plugin = vim-test;
        config = ''
          let test#strategy = "neovim"
          let test#neovim#term_position = "vert botright"
          lua << EOF
          vim.keymap.set('n', '<Leader>tt', ':TestNearest<CR>', { noremap = true, desc = "Test nearest" })
          vim.keymap.set('n', '<Leader>tT', ':TestFile<CR>', { noremap = true, desc = "Test file" })
          vim.keymap.set('n', '<Leader>ts', ':TestSuite<CR>', { noremap = true, desc = "Test suite" })
          vim.keymap.set('n', '<Leader>tl', ':TestLast<CR>', { noremap = true, desc = "Test last" })
          vim.keymap.set('n', '<Leader>tv', ':TestVisit<CR>', { noremap = true, desc = "Test visit" })
          EOF
        '';
      }
      mkdir-nvim
      nvim-ts-autotag
      telescope-fzf-native-nvim
      vim-advanced-sorters
      vim-easy-align
      vim-endwise
      vim-fugitive
      vim-repeat
      vim-sleuth
      vim-surround
    ] ++
    lib.optionals (!pkgs.stdenv.isDarwin) [
      # give [?] icons in macOS
      nvim-web-devicons
    ];
  };
}

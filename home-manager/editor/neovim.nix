{ config, pkgs, lib, ... }:

let
  devCfg = config.home-manager.dev;
  cfg = config.home-manager.editor.neovim;
  toLuaBool = x: if x then "true" else "false";
in
{
  options.home-manager.editor.neovim = {
    enable = lib.mkEnableOption "Neovim config" // {
      default = config.home-manager.editor.enable;
    };
    # Do not forget to set 'Hack Nerd Mono Font' as the terminal font
    enableIcons = lib.mkEnableOption "icons" // {
      default = config.home-manager.desktop.enable || config.home-manager.darwin.enable;
    };
    enableLsp = lib.mkEnableOption "LSP" // {
      default = config.home-manager.dev.enable;
    };
    enableTreeSitter = lib.mkEnableOption "TreeSitter" // {
      default = config.home-manager.dev.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      ripgrep
    ]
    # For clipboard=unnamedplus
    ++ lib.optionals stdenv.isLinux [
      wl-clipboard
      xclip
    ]
    ++ lib.optionals cfg.enableIcons [
      config.home-manager.desktop.theme.fonts.symbols.package
    ];

    programs.neovim = {
      enable = true;
      defaultEditor = true;

      withRuby = false;
      withNodeJs = false;
      withPython3 = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      extraLuaConfig = /* lua */ ''
        -- general config
        -- show line numbers
        vim.opt.number = true

        -- turn on omnicomplete
        vim.opt.omnifunc = "syntaxcomplete#Complete"

        -- live substitutions as you type
        vim.opt.inccommand = 'nosplit'

        -- copy and paste use the system clipboard
        vim.opt.clipboard:append { 'unnamedplus' }

        -- show vertical colum
        vim.opt.colorcolumn:append { 81, 121 }

        -- threat words-with-dash as a word
        vim.opt.iskeyword:append { '-' }

        -- disable "How to disable mouse" menu
        vim.cmd.aunmenu { [[PopUp.How-to\ disable\ mouse]] }
        vim.cmd.aunmenu { [[PopUp.-1-]] }

        -- window movement mappings
        vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]])
        vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]])
        vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]])
        vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]])
        vim.keymap.set('n', '<C-h>', '<C-w>h')
        vim.keymap.set('n', '<C-j>', '<C-w>j')
        vim.keymap.set('n', '<C-k>', '<C-w>k')
        vim.keymap.set('n', '<C-l>', '<C-w>l')
        vim.keymap.set({'i', 'v'}, '<C-h>', '<Esc><C-w>h')
        vim.keymap.set({'i', 'v'}, '<C-j>', '<Esc><C-w>j')
        vim.keymap.set({'i', 'v'}, '<C-k>', '<Esc><C-w>k')
        vim.keymap.set({'i', 'v'}, '<C-l>', '<Esc><C-w>l')

        -- make Esc enter Normal mode in Term
        vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]])
        vim.keymap.set('t', '<M-[>', [[<C-\><C-n>]])
        vim.keymap.set('t', '<C-v><Esc>', [[<C-\><C-n>]])

        -- unsets the 'last search pattern'
        vim.keymap.set('n', '<C-g>', '<cmd>:noh<CR><CR>')

        -- completion
        vim.opt.completeopt = 'menu'
        vim.keymap.set('i', '<C-Space>', '<C-x><C-o>')

        -- syntax highlight flake.lock files as json
        vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
          pattern = 'flake.lock',
          command = 'set filetype=json',
        })

        -- keep comment leader when 'o' or 'O' is used in Normal mode
        vim.api.nvim_create_autocmd({ 'FileType' }, {
          pattern = '*',
          command = 'set formatoptions+=o',
        })
      '';

      # To install non-packaged plugins, use
      # pkgs.vimUtils.buildVimPluginFrom2Nix { }
      plugins = with pkgs; with vimPlugins; [
        {
          # FIXME: dummy plugin since there is no way currently to set a config
          # before the plugins are initialized
          # See: https://github.com/nix-community/home-manager/pull/2391
          plugin = pkgs.writeText "00-init-pre" "";
          config = /* vim */ ''
            " remap leader
            let g:mapleader = "\<Space>"
            let g:maplocalleader = ','
          '';
        }
        {
          plugin = undotree;
          config = /* vim */ ''
            if !isdirectory($HOME . "/.config/nvim/undotree")
                call mkdir($HOME . "/.config/nvim/undotree", "p", 0755)
            endif

            set undofile
            set undodir=~/.config/nvim/undotree
            let undotree_WindowLayout = 3
            lua << EOF
            vim.keymap.set('n', '<Leader>u', ':UndotreeToggle<CR>', { desc = "Undotree toggle" })
            EOF
          '';
        }
        {
          plugin = vim-polyglot;
          config = /* vim */ ''
            " use a simpler and faster regex to parse CSV
            " does not work with CSVs where the delimiter is quoted inside the field
            " let g:csv_strict_columns = 1
            " disabled CSV concealing (e.g.: `,` -> `|`), also faster
            let g:csv_no_conceal = 1
          '';
        }
        {
          plugin = vim-sneak;
          config = /* vim */ ''
            let g:sneak#label = 1
            map f <Plug>Sneak_f
            map F <Plug>Sneak_F
            map t <Plug>Sneak_t
            map T <Plug>Sneak_T
          '';
        }
        {
          plugin = vim-test;
          config = /* vim */ ''
            let g:test#strategy = "neovim"
            let g:test#neovim#start_normal = 1
            let g:test#neovim#term_position = "vert botright"
            lua << EOF
            vim.keymap.set('n', '<Leader>tt', ':TestNearest<CR>', { desc = "Test nearest" })
            vim.keymap.set('n', '<Leader>tT', ':TestFile<CR>', { desc = "Test file" })
            vim.keymap.set('n', '<Leader>ts', ':TestSuite<CR>', { desc = "Test suite" })
            vim.keymap.set('n', '<Leader>tl', ':TestLast<CR>', { desc = "Test last" })
            vim.keymap.set('n', '<Leader>tv', ':TestVisit<CR>', { desc = "Test visit" })
            EOF
          '';
        }
        {
          plugin = pkgs.writeText "01-init-pre-lua" "";
          type = "lua";
          config = /* lua */ ''
            -- bytecompile lua modules
            vim.loader.enable()

            -- load .exrc, .nvimrc and .nvim.lua local files
            vim.o.exrc = true
          '';
        }
        {
          plugin = comment-nvim;
          type = "lua";
          config = /* lua */ ''
            require('Comment').setup {}
          '';
        }
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config = /* lua */ ''
            require('gitsigns').setup {}
          '';
        }
        {
          plugin = lir-nvim;
          type = "lua";
          config = /* lua */ ''
            -- disable netrw
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1

            local actions = require('lir.actions')
            local mark_actions = require('lir.mark.actions')
            local clipboard_actions = require('lir.clipboard.actions')
            local enable_icons = ${toLuaBool cfg.enableIcons}

            require('lir').setup {
              show_hidden_files = false,
              ignore = {},
              devicons = {
                enable = enable_icons,
                highlight_dirname = false,
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
              { desc = "Files" }
            )
          '';
        }
        {
          plugin = lualine-nvim;
          type = "lua";
          # TODO: add support for trailing whitespace
          config = /* lua */ ''
            local enable_icons = ${toLuaBool cfg.enableIcons}

            require('lualine').setup {
              options = {
                icons_enabled = enable_icons,
              },
            }
          '';
        }
        {
          plugin = nvim-autopairs;
          type = "lua";
          config = /* lua */ ''
            require("nvim-autopairs").setup {}
          '';
        }
        {
          plugin = onedarkpro-nvim;
          type = "lua";
          config = /* lua */ ''
            vim.cmd("colorscheme onedark")
          '';
        }
        {
          plugin = openingh-nvim;
          type = "lua";
          config = /* lua */ ''
            -- for repository page
            vim.keymap.set({'n', 'v'}, '<Leader>gr', ":OpenInGHRepo <CR>", { silent = true, desc = "Open in GitHub repo" })

            -- for current file page
            vim.keymap.set('n', '<Leader>gf', ":OpenInGHFile <CR>", { silent = true, desc = "Open in GitHub file" })
            vim.keymap.set('v', '<Leader>gf', ":OpenInGHFileLines <CR>", { silent = true, desc = "Open in GitHub lines" })
          '';
        }
        {
          plugin = other-nvim;
          type = "lua";
          config = /* lua */ ''
            require("other-nvim").setup {
              mappings = {
                "livewire",
                "angular",
                "laravel",
                "rails",
                "golang",
              },
            }

            vim.keymap.set("n", "<leader>aa", "<cmd>:Other<CR>", { silent = true, desc = "Other" })
            vim.keymap.set("n", "<leader>as", "<cmd>:OtherSplit<CR>", { silent = true, desc = "Other h-split" })
            vim.keymap.set("n", "<leader>av", "<cmd>:OtherVSplit<CR>", { silent = true, desc = "Other v-split" })
            vim.keymap.set("n", "<leader>ac", "<cmd>:OtherClear<CR>", { silent = true, desc = "Other clear" })

            -- Context specific bindings
            vim.keymap.set("n", "<leader>at", "<cmd>:Other test<CR>", { silent = true, desc = "Other test" })
          '';
        }
        {
          plugin = project-nvim;
          type = "lua";
          config = /* lua */ ''
            require('project_nvim').setup {}
            vim.keymap.set(
              'n',
              '<Leader>p',
              ":Telescope projects<CR>",
              { desc = "Projects" }
            )
          '';
        }
        {
          plugin = remember-nvim;
          type = "lua";
          config = /* lua */ ''
            require('remember').setup {}
          '';
        }
        {
          plugin = telescope-nvim;
          type = "lua";
          config = /* lua */ ''
            local actions = require('telescope.actions')
            local telescope = require('telescope')
            telescope.setup {
              defaults = {
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
                -- configure to use ripgrep
                vimgrep_arguments = {
                  "${lib.getExe pkgs.ripgrep}",
                  "--follow",        -- Follow symbolic links
                  "--hidden",        -- Search for hidden files
                  "--no-heading",    -- Don't group matches by each file
                  "--with-filename", -- Print the file path with the matched lines
                  "--line-number",   -- Show line numbers
                  "--column",        -- Show column numbers
                  "--smart-case",    -- Smart case search

                  -- Exclude some patterns from search
                  "--glob=!**/.git/*",
                  "--glob=!**/.idea/*",
                  "--glob=!**/.vscode/*",
                },
              },
              pickers = {
                find_files = {
                  hidden = true,
                  -- needed to exclude some files & dirs from general search
                  -- when not included or specified in .gitignore
                  find_command = {
                    "${lib.getExe pkgs.ripgrep}",
                    "--files",
                    "--hidden",
                    "--glob=!**/.git/*",
                    "--glob=!**/.idea/*",
                    "--glob=!**/.vscode/*",
                  },
                },
              },
            }
            telescope.load_extension('fzf')
            telescope.load_extension('projects')

            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<Leader><Leader>', builtin.find_files, { desc = "Find files" })
            vim.keymap.set('n', '<Leader>/', builtin.live_grep, { desc = "Live grep" })
            vim.keymap.set({'n', 'v'}, '<Leader>*', builtin.grep_string, { desc = "Grep string" })
          '';
        }
        {
          plugin = which-key-nvim;
          type = "lua";
          config = /* lua */ ''
            vim.o.timeout = true
            vim.o.timeoutlen = 300
            require("which-key").setup {}
          '';
        }
        {
          plugin = whitespace-nvim;
          type = "lua";
          config = /* lua */ ''
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
              { desc = "Trim whitespace" }
            )
          '';
        }
        mkdir-nvim
        telescope-fzf-native-nvim
        vim-advanced-sorters
        vim-easy-align
        vim-endwise
        vim-fugitive
        vim-repeat
        vim-sexp
        vim-sexp-mappings-for-regular-people
        vim-sleuth
        vim-surround
        {
          # Workaround issue with those mappings being overwritten by some
          # plugins, needs to be Lua since it needs to load later than
          # vimscript
          plugin = pkgs.writeText "50-completion-maps" "";
          type = "lua";
          config = /* lua */ ''
            local opts = { silent = true, expr = true }
            local keys = { 'i', 'c' }

            vim.keymap.set(keys, '<C-j>', function() return vim.fn.pumvisible() ~= 0 and '<C-n>' or '<C-j>' end, opts)
            vim.keymap.set(keys, '<C-k>', function() return vim.fn.pumvisible() ~= 0 and '<C-p>' or '<C-k>' end, opts)
            vim.keymap.set(keys, '<CR>', function() return vim.fn.pumvisible() ~= 0 and '<C-y>' or '<CR>' end, opts)
          '';
        }
      ]
      ++ lib.optionals cfg.enableLsp [
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = /* lua */ ''
            -- Setup language servers.
            -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
            local lspconfig = require('lspconfig')

            ${lib.optionalString devCfg.enable /* lua */ ''
              lspconfig.bashls.setup {}
              lspconfig.marksman.setup {}
            ''}
            ${lib.optionalString devCfg.nix.enable /* lua */ ''
              lspconfig.nil_ls.setup {
                settings = {
                  ['nil'] = {
                    formatting = {
                      command = { "nixpkgs-fmt" },
                    },
                  },
                },
              }
            ''}
            ${lib.optionalString devCfg.clojure.enable /* lua */ ''
              lspconfig.clojure_lsp.setup {}
            ''}
            ${lib.optionalString devCfg.go.enable /* lua */ ''
              lspconfig.gopls.setup {}
            ''}
            ${lib.optionalString devCfg.python.enable /* lua */ ''
              lspconfig.pyright.setup {}
              lspconfig.ruff_lsp.setup {}
            ''}
            ${lib.optionalString devCfg.node.enable /* lua */''
              lspconfig.cssls.setup {}
              lspconfig.eslint.setup {}
              lspconfig.html.setup {}
              lspconfig.jsonls.setup {}
            ''}

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
          '';
        }
      ]
      ++ lib.optionals cfg.enableTreeSitter [
        {
          plugin = nvim-treesitter.withAllGrammars;
          type = "lua";
          config = /* lua */ ''
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
          '';
        }
        nvim-ts-autotag
      ]
      ++ lib.optionals cfg.enableIcons [
        nvim-web-devicons
      ];
    };

    xdg.desktopEntries.nvim = lib.mkIf config.home-manager.desktop.enable {
      name = "Neovim";
      genericName = "Text Editor";
      comment = "Edit text files";
      exec = "nvim %F";
      icon = "nvim";
      mimeType = [
        "text/english"
        "text/plain"
        "text/x-makefile"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
        "application/x-shellscript"
        "text/x-c"
        "text/x-c++"
      ];
      terminal = true;
      type = "Application";
      categories = [ "Utility" "TextEditor" ];
    };
  };
}

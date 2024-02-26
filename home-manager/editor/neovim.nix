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
    enableCmp = lib.mkEnableOption "nvim-cmp and nvim-snippy" // {
      default = config.home-manager.dev.enable;
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
      fd
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
      withPython3 = false;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      extraLuaConfig = /* lua */ ''
        -- general config

        -- reload unchanged files automatically
        vim.opt.autoread = true

        -- autoindent when starting a new line with 'o' or 'O'
        vim.opt.autoindent = true

        -- indent wrapped lines to match line start
        vim.opt.breakindent = true

        -- show line numbers
        vim.opt.number = true

        -- ignore case in search, except if using case
        vim.opt.ignorecase = true
        vim.opt.smartcase = true

        -- show search results while typing
        vim.opt.incsearch = true

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

        -- avoid swapfile warning
        vim.opt.shortmess = 'A'

        -- persistent undo
        local undodir = vim.fn.expand('~/.config/nvim/undo')

        vim.opt.undofile = true
        vim.opt.undodir = undodir

        if vim.fn.isdirectory(undodir) ~= 0 then
          vim.fn.mkdir(undodir, "p", 0755)
        end

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
        vim.keymap.set({'i', 'c'}, '<C-j>', function()
          return vim.fn.pumvisible() ~= 0 and '<C-n>' or '<C-j>'
        end, { expr = true })
        vim.keymap.set({'i', 'c'}, '<C-k>', function()
          return vim.fn.pumvisible() ~= 0 and '<C-p>' or '<C-k>'
        end, { expr = true })
        -- the insert mode mapping for this one is done in vim-endwise
        vim.keymap.set('c', '<CR>', function()
          return vim.fn.pumvisible() ~= 0 and '<C-y>' or '<CR>'
        end, { expr = true })
        ${lib.optionalString (!cfg.enableCmp) /* lua */ ''
          vim.keymap.set('i', '<C-Space>', '<C-x><C-o>')
        ''}

        -- syntax highlight flake.lock files as json
        vim.api.nvim_create_autocmd({'BufNewFile', 'BufRead'}, {
          pattern = 'flake.lock',
          command = 'set filetype=json',
        })

        -- keep comment leader when 'o' or 'O' is used in Normal mode
        vim.api.nvim_create_autocmd({'FileType'}, {
          pattern = '*',
          command = 'set formatoptions+=o',
        })
      '';

      # To install non-packaged plugins, use
      # pkgs.vimUtils.buildVimPlugin { }
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
            require("Comment").setup {}
          '';
        }
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config = /* lua */ ''
            require("gitsigns").setup {}
          '';
        }
        {
          plugin = leap-nvim;
          type = "lua";
          config = /* lua */ ''
            require("leap").create_default_mappings()
          '';
        }
        {
          plugin = lualine-nvim;
          type = "lua";
          config = /* lua */ ''
            local enable_icons = ${toLuaBool cfg.enableIcons}
            local function mixed_indent()
              local space_pat = [[\v^ +]]
              local tab_pat = [[\v^\t+]]
              local space_indent = vim.fn.search(space_pat, 'nwc')
              local tab_indent = vim.fn.search(tab_pat, 'nwc')
              local mixed = (space_indent > 0 and tab_indent > 0)
              local mixed_same_line
              if not mixed then
                mixed_same_line = vim.fn.search([[\v^(\t+ | +\t)]], 'nwc')
                mixed = mixed_same_line > 0
              end
              if not mixed then return "" end
              if mixed_same_line ~= nil and mixed_same_line > 0 then
                 return "mixed[".. mixed_same_line .. "]"
              end
              local space_indent_cnt = vim.fn.searchcount({pattern=space_pat, max_count=1e3}).total
              local tab_indent_cnt =  vim.fn.searchcount({pattern=tab_pat, max_count=1e3}).total
              if space_indent_cnt > tab_indent_cnt then
                return "mixed[" .. tab_indent .. "]"
              else
                return "mixed[" .. space_indent .. "]"
              end
            end
            local function trailing_whitespace()
              local space = vim.fn.search([[\s\+$]], 'nwc')
              return space ~= 0 and "trailing[" .. space .. "]" or ""
            end

            require("lualine").setup {
              sections = {
                lualine_y = { mixed_indent },
                lualine_z = { trailing_whitespace },
              },
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
            local enable_ts = ${toLuaBool cfg.enableTreeSitter}

            require("nvim-autopairs").setup {
              check_ts = enable_ts
            }
          '';
        }
        {
          plugin = nvim-surround;
          type = "lua";
          config = /* lua */ ''
            require("nvim-surround").setup {}
          '';
        }
        {
          plugin = oil-nvim.overrideAttrs (oldAttrs: {
            # https://github.com/stevearc/oil.nvim/pull/305
            patches = [
              (fetchpatch {
                url = "https://github.com/pi314ever/oil.nvim/commit/4e71530846202c71771d03f7d16506a87cbd86aa.patch";
                hash = "sha256-qVFDcpthtIFSsZa/Jok/62RY0NseZaCciO4vB9H5WEM=";
              })
              (fetchpatch {
                url = "https://github.com/pi314ever/oil.nvim/commit/7743b4c39a31a517fa13a01e48ae44d0cf1129a9.patch";
                hash = "sha256-CZiwU2D5mtx6jTPJJdIVf2TKN1a5YdTWkq31oeznUwM=";
              })
              (fetchpatch {
                url = "https://github.com/pi314ever/oil.nvim/commit/65b26c30f0881514acc6a6fdf1319458ed16e983.patch";
                hash = "sha256-PdCCfcUq1lLEAOptnv8sLqW6nMa/QfO/1cpU3ompCGU=";
              })
            ];
          });
          type = "lua";
          config = /* lua */ ''
            local oil = require("oil")
            oil.setup {
              default_file_explorer = true,
              skip_confirm_for_simple_edits = true,
              constrain_cursor = "name",
              lsp_rename_autosave = true,
              experimental_watch_for_changes = true,
            }

            vim.keymap.set("n", "-", oil.open, { desc = "Open parent directory" })
          '';
        }
        {
          plugin = onedarkpro-nvim;
          type = "lua";
          config = /* lua */ ''
            vim.cmd.colorscheme("onedark")
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
          plugin = remember-nvim;
          type = "lua";
          config = /* lua */ ''
            require("remember").setup {}
          '';
        }
        {
          plugin = telescope-nvim;
          type = "lua";
          config = /* lua */ ''
            local actions = require("telescope.actions")
            local builtin = require("telescope.builtin")
            local telescope = require("telescope")
            local undo_actions = require("telescope-undo.actions")
            -- Exclude some patterns from search
            local rg_common_args = {
              "--glob=!**/.git/*",
              "--glob=!**/.hg/*",
              "--glob=!**/.svn/*",
              "--glob=!**/.bzr/*",

              "--glob=!**/.DS_Store/*",
              "--glob=!**/node_modules/*",
              "--glob=!**/.idea/*",
              "--glob=!**/.vscode/*",
            }

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
                  unpack(rg_common_args)
                },
              },
              pickers = {
                find_files = {
                  -- needed to exclude some files & dirs from general search
                  -- when not included or specified in .gitignore
                  find_command = {
                    "${lib.getExe pkgs.ripgrep}",
                    "--files",
                    "--hidden",
                    unpack(rg_common_args)
                  },
                },
              },
              extensions = {
                undo = {
                  mappings = {
                    i = {
                      ["<cr>"] = undo_actions.restore,
                      ["<S-cr>"] = undo_actions.yank_deletions,
                      ["<C-cr>"] = undo_actions.yank_additions,
                      ["<C-y>"] = undo_actions.yank_deletions,
                      ["<C-r>"] = undo_actions.restore,
                    },
                    n = {
                      ["u"] = undo_actions.restore,
                      ["y"] = undo_actions.yank_additions,
                      ["Y"] = undo_actions.yank_deletions,
                    },
                  },
                },
              },
            }
            telescope.load_extension('fzf')
            telescope.load_extension('projects')
            telescope.load_extension('ui-select')
            telescope.load_extension('undo')

            vim.keymap.set('n', '<Leader><Leader>', builtin.find_files, { desc = "Find files" })
            vim.keymap.set('n', '<Leader>/', builtin.live_grep, { desc = "Live grep" })
            vim.keymap.set({'n', 'v'}, '<Leader>*', builtin.grep_string, { desc = "Grep string" })
            vim.keymap.set('n', '<Leader>u', telescope.extensions.undo.undo, { desc = "Undo" })
          '';
        }
        # telescope extensions
        {
          plugin = project-nvim;
          type = "lua";
          config = /* lua */ ''
            require("project_nvim").setup {}
            vim.keymap.set('n', '<Leader>p', telescope.extensions.projects.projects, { desc = "Projects" })
          '';
        }
        telescope-fzf-native-nvim
        telescope-ui-select-nvim
        telescope-undo-nvim
        {
          plugin = vim-easy-align;
          type = "lua";
          config = /* lua */ ''
            vim.keymap.set({'n', 'x'}, 'ga', '<Plug>(EasyAlign)', { remap = true })
          '';
        }
        {
          plugin = vim-endwise;
          type = "lua";
          config = /* lua */ ''
            vim.g.endwise_no_mappings = 1

            vim.keymap.set('i', '<CR>', function()
              return vim.fn.pumvisible() ~= 0 and '<C-y>' or vim.fn.EndwiseAppend(
                vim.api.nvim_replace_termcodes('<CR>', true, true, true)
              )
            end, { expr = true })
          '';
        }
        {
          plugin = vim-test;
          type = "lua";
          config = /* lua */ ''
            vim.g["test#strategy"] = "neovim"
            vim.g["test#neovim#start_normal"] = 1
            vim.g["test#neovim#term_position"] = "vert botright"

            vim.keymap.set('n', '<Leader>tt', ':TestNearest<CR>', { desc = "Test nearest" })
            vim.keymap.set('n', '<Leader>tT', ':TestFile<CR>', { desc = "Test file" })
            vim.keymap.set('n', '<Leader>ts', ':TestSuite<CR>', { desc = "Test suite" })
            vim.keymap.set('n', '<Leader>tl', ':TestLast<CR>', { desc = "Test last" })
            vim.keymap.set('n', '<Leader>tv', ':TestVisit<CR>', { desc = "Test visit" })
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
            local whitespace = require("whitespace-nvim")
            whitespace.setup {
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
            vim.keymap.set('n', '<Leader>w', whitespace.trim, { desc = "Trim whitespace" })
          '';
        }
        mkdir-nvim
        vim-advanced-sorters
        vim-fugitive
        vim-sleuth
      ]
      ++ lib.optionals cfg.enableCmp [
        cmp-nvim-lsp
        cmp-path
        cmp-snippy
        {
          plugin = nvim-cmp;
          type = "lua";
          config = /* lua */ ''
            local cmp = require("cmp")
            cmp.setup({
              completion = { autocomplete = false },
              mapping = {
                ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-k>'] = cmp.mapping.select_prev_item(),
                ['<C-j>'] = cmp.mapping.select_next_item(),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.abort(),
                ['<CR>'] = cmp.mapping.confirm(),
              },
              snippet = {
                expand = function(args)
                  require("snippy").expand_snippet(args.body)
                end,
              },
              sources = {
                { name = 'nvim_lsp' },
                { name = 'path' },
                { name = 'snippy' },
              },
            })
          '';
        }
        {
          plugin = nvim-snippy;
          type = "lua";
          config = /* lua */ ''
            require("snippy").setup {}
            local mappings = require("snippy.mapping")

            vim.keymap.set('i', '<Tab>', mappings.expand_or_advance('<Tab>'), { desc = "Snippy expand or advance" })
            vim.keymap.set('s', '<Tab>', mappings.next('<Tab>'), { desc = "Snippy next" })
            vim.keymap.set({'i', 's'}, '<S-Tab>', mappings.previous('<S-Tab>'), { desc = "Snippy previous" })
            vim.keymap.set({'n', 'x'}, '<Leader>x', mappings.cut_text, { remap = true, desc = "Snippy delete" })
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
            local lspconfig = require("lspconfig")
            local capabilities = {}
            ${lib.optionalString cfg.enableCmp /* lua */ ''
              capabilities = require("cmp_nvim_lsp").default_capabilities()
            ''}

            ${lib.optionalString devCfg.enable /* lua */ ''
              lspconfig.bashls.setup { capabilities = capabilities }
              lspconfig.marksman.setup { capabilities = capabilities }
            ''}
            ${lib.optionalString devCfg.nix.enable /* lua */ ''
              lspconfig.nil_ls.setup {
                capabilities = capabilities,
                settings = {
                  ['nil'] = {
                    formatting = {
                      command = { "nixpkgs-fmt" },
                    },
                    nix = {
                      flake = {
                        autoArchive = false,
                      },
                    },
                  },
                },
              }
            ''}
            ${lib.optionalString devCfg.clojure.enable /* lua */ ''
              lspconfig.clojure_lsp.setup { capabilities = capabilities }
            ''}
            ${lib.optionalString devCfg.go.enable /* lua */ ''
              lspconfig.gopls.setup { capabilities = capabilities }
            ''}
            ${lib.optionalString devCfg.python.enable /* lua */ ''
              lspconfig.pyright.setup { capabilities = capabilities }
              lspconfig.ruff_lsp.setup { capabilities = capabilities }
            ''}
            ${lib.optionalString devCfg.node.enable /* lua */''
              lspconfig.cssls.setup { capabilities = capabilities }
              lspconfig.eslint.setup { capabilities = capabilities }
              lspconfig.html.setup { capabilities = capabilities }
              lspconfig.jsonls.setup { capabilities = capabilities }
            ''}

            local builtin = require("telescope.builtin")

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
                vim.keymap.set({'n', 'v'}, '<Leader>la', vim.lsp.buf.code_action, { buffer = ev.buf, desc = "LSP code action" })
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
          plugin = nvim-ufo;
          type = "lua";
          config = /* lua */ ''
            local ufo = require("ufo")

            vim.o.foldcolumn = '0'
            vim.o.foldlevel = 99
            vim.o.foldlevelstart = 99
            vim.o.foldenable = true

            vim.keymap.set('n', 'zR', ufo.openAllFolds)
            vim.keymap.set('n', 'zM', ufo.closeAllFolds)
            ufo.setup {
              provider_selector = function(bufnr, filetype, buftype)
                return {'treesitter', 'indent'}
              end
            }
          '';
        }
        {
          plugin = nvim-treesitter.withAllGrammars;
          type = "lua";
          config = /* lua */ ''
            require("nvim-treesitter.configs").setup {
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
              textobjects = {
                select = {
                  enable = true,

                  -- Automatically jump forward to textobj, similar to targets.vim
                  lookahead = true,

                  keymaps = {
                    ["af"] = { query = "@function.outer", desc = "Select outer part of a function region" },
                    ["if"] = { query = "@function.inner", desc = "Select inner part of a function region" },
                    ["ac"] = { query = "@class.outer", desc = "Select outer part of a class region" },
                    ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                    ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
                  },

                  -- You can choose the select mode (default is charwise 'v')
                  selection_modes = {
                    ['@parameter.outer'] = 'v', -- charwise
                    ['@function.outer'] = 'V', -- linewise
                    ['@class.outer'] = '<c-v>', -- blockwise
                  },

                  -- If you set this to `true` (default is `false`) then any textobject is
                  -- extended to include preceding or succeeding whitespace. Succeeding
                  -- whitespace has priority in order to act similarly to eg the built-in
                  -- `ap`.
                  include_surrounding_whitespace = false,
                },
                swap = {
                  enable = true,
                  swap_next = {
                    ["<leader>a"] = { query = "@parameter.inner", desc = "Swap parameter with next" },
                  },
                  swap_previous = {
                    ["<leader>A"] = { query = "@parameter.inner", desc = "Swap parameter with previous" },
                  },
                },
                move = {
                  enable = true,
                  set_jumps = true, -- whether to set jumps in the jumplist
                  goto_next_start = {
                    ["]m"] = { query = "@function.outer", desc = "Next function start" },
                    ["]]"] = { query = "@class.outer", desc = "Next class start" },
                  },
                  goto_next_end = {
                    ["]M"] = { query = "@function.outer", desc = "Next function end" },
                    ["]["] = { query = "@class.outer", desc = "Next class end" },
                  },
                  goto_previous_start = {
                    ["[m"] = { query = "@function.outer", desc = "Previous function start" },
                    ["[["] = { query = "@class.outer", desc = "Previous class start" },
                  },
                  goto_previous_end = {
                    ["[M"] = { query = "@function.outer", desc = "Previous function end" },
                    ["[]"] = { query = "@class.outer", desc = "Previous class end" },
                  },
                  -- Below will go to either the start or the end, whichever is closer.
                  goto_next = {
                    ["]d"] = "@conditional.outer",
                  },
                  goto_previous = {
                    ["[d"] = "@conditional.outer",
                  }
                },
              },
            }
          '';
        }
        {
          plugin = nvim-treesitter-textobjects;
          type = "lua";
          config = /* lua */ ''
            -- most config is in nvim-treesitter itself
            local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

            -- vim way: ; goes to the direction you were moving.
            vim.keymap.set({"n", "x", "o"}, ";", ts_repeat_move.repeat_last_move)
            vim.keymap.set({"n", "x", "o"}, ",", ts_repeat_move.repeat_last_move_opposite)

            -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
            vim.keymap.set({"n", "x", "o"}, "f", ts_repeat_move.builtin_f)
            vim.keymap.set({"n", "x", "o"}, "F", ts_repeat_move.builtin_F)
            vim.keymap.set({"n", "x", "o"}, "t", ts_repeat_move.builtin_t)
            vim.keymap.set({"n", "x", "o"}, "T", ts_repeat_move.builtin_T)
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
        "application/x-shellscript"
        "text/english"
        "text/plain"
        "text/x-c"
        "text/x-c++"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-makefile"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
      ];
      terminal = true;
      type = "Application";
      categories = [ "Utility" "TextEditor" ];
    };
  };
}

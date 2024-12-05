{
  config,
  pkgs,
  lib,
  flake,
  ...
}:

let
  cfg = config.home-manager.editor.neovim;
  toLua = lib.generators.toLua { };
  # Custom autocmds for filetypes
  # { "<pattern>" = "<command>"; }
  # E.g.: { "*.json" = "set filetype=json"; }
  customAutocmds = {
    "flake.lock" = "set filetype=json";
    "*.md" = "setlocal spell spelllang=en";
  };
in
{
  options.home-manager.editor.neovim = {
    enable = lib.mkEnableOption "Neovim config" // {
      default = config.home-manager.editor.enable;
    };
    # Do not forget to set 'Hack Nerd Mono Font' as the terminal font
    icons.enable = lib.mkEnableOption "icons" // {
      default = config.home-manager.desktop.enable || config.home-manager.darwin.enable;
    };
    cmp.enable = lib.mkEnableOption "nvim-cmp and nvim-snippy" // {
      default = config.home-manager.dev.enable;
    };
    markdownPreview.enable = lib.mkEnableOption "markdown-preview.nvim" // {
      default = config.home-manager.desktop.enable || config.home-manager.darwin.enable;
    };
    lsp.enable = lib.mkEnableOption "LSP" // {
      default = config.home-manager.dev.enable;
    };
    treeSitter.enable = lib.mkEnableOption "TreeSitter" // {
      default = config.home-manager.dev.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        fd
        ripgrep
      ]
      ++ lib.optionals stdenv.isLinux [
        fswatch
        # For clipboard=unnamedplus
        wl-clipboard
        xclip
      ]
      ++ lib.optionals cfg.icons.enable [ config.home-manager.desktop.theme.fonts.symbols.package ];

    programs.neovim = {
      enable = true;

      defaultEditor = true;

      withRuby = false;
      withNodeJs = cfg.markdownPreview.enable;
      withPython3 = false;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      extraLuaConfig = # lua
        ''
          -- general config
          vim.g.mapleader = ' '
          vim.g.maplocalleader = ','

          -- bytecompile lua modules
          vim.loader.enable()

          -- load .exrc, .nvimrc and .nvim.lua local files
          vim.opt.exrc = true

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
          vim.opt.inccommand = "nosplit"

          -- copy and paste use the system clipboard
          vim.opt.clipboard:append { "unnamedplus" }

          -- show vertical colum
          vim.opt.colorcolumn:append { 81, 121 }

          -- avoid swapfile warning
          vim.opt.shortmess:append { A = true }

          -- persistent undo
          local undodir = vim.fn.expand("~/.config/nvim/undo")
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
          vim.opt.completeopt = 'menu,menuone,noinsert,noselect'
          vim.keymap.set({'i', 'c'}, '<C-j>', function()
            return vim.fn.pumvisible() ~= 0 and '<C-n>' or '<C-j>'
          end, { expr = true })
          vim.keymap.set({'i', 'c'}, '<C-k>', function()
            return vim.fn.pumvisible() ~= 0 and '<C-p>' or '<C-k>'
          end, { expr = true })
          vim.keymap.set({'i', 'c'}, '<CR>', function()
            return vim.fn.pumvisible() ~= 0 and '<C-y>' or '<CR>'
          end, { expr = true })
          ${lib.optionalString (!cfg.cmp.enable) # lua
            ''
              vim.keymap.set('i', '<C-Space>', '<C-x><C-o>')
            ''
          }

          ${lib.concatStringsSep "\n" (
            lib.mapAttrsToList (
              pattern: command: # lua
              ''
                vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
                  pattern = { "${pattern}" },
                  command = "${command}",
                })
              '') customAutocmds
          )}

          -- reload file if changed
          vim.opt.autoread = true
          vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
            command = "if mode() != 'c' | checktime | endif",
            pattern = { "*" },
          })

          -- autoindent when starting a new line with 'o' or 'O'
          vim.opt.autoindent = true
          -- keep comment leader when 'o' or 'O' is used in Normal mode
          -- remove comment character when joining commented lines
          vim.api.nvim_create_autocmd({ "FileType" }, {
            pattern = { "*" },
            command = "set formatoptions+=oj",
          })
        '';

      # To install non-packaged plugins, use
      # pkgs.vimUtils.buildVimPlugin { }
      plugins =
        with pkgs;
        with vimPlugins;
        [
          {
            plugin = dial-nvim;
            type = "lua";
            config = # lua
              ''
                local dial_map = require("dial.map")
                vim.keymap.set("n", "<C-a>", function()
                    dial_map.manipulate("increment", "normal")
                end, { desc = "Increment" })
                vim.keymap.set("n", "<C-x>", function()
                    dial_map.manipulate("decrement", "normal")
                end, { desc = "Decrement" })
                vim.keymap.set("n", "g<C-a>", function()
                    dial_map.manipulate("increment", "gnormal")
                end, { desc = "Increment" })
                vim.keymap.set("n", "g<C-x>", function()
                    dial_map.manipulate("decrement", "gnormal")
                end, { desc = "Decrement" })
                vim.keymap.set("v", "<C-a>", function()
                    dial_map.manipulate("increment", "visual")
                end, { desc = "Increment" })
                vim.keymap.set("v", "<C-x>", function()
                    dial_map.manipulate("decrement", "visual")
                end, { desc = "Decrement" })
                vim.keymap.set("v", "g<C-a>", function()
                    dial_map.manipulate("increment", "gvisual")
                end, { desc = "Increment" })
                vim.keymap.set("v", "g<C-x>", function()
                    dial_map.manipulate("decrement", "gvisual")
                end, { desc = "Decrement" })
              '';
          }
          {
            plugin = gitsigns-nvim;
            type = "lua";
            config = # lua
              ''
                require("gitsigns").setup {}
              '';
          }
          {
            plugin = guess-indent-nvim;
            type = "lua";
            config = # lua
              ''
                require("guess-indent").setup {}
              '';
          }
          {
            plugin = leap-nvim;
            type = "lua";
            config = # lua
              ''
                require("leap").create_default_mappings()
              '';
          }
          {
            plugin = lir-nvim;
            type = "lua";
            config = # lua
              ''
                -- disable netrw
                vim.g.loaded_netrw = 1
                vim.g.loaded_netrwPlugin = 1

                local actions = require('lir.actions')
                local mark_actions = require('lir.mark.actions')
                local clipboard_actions = require('lir.clipboard.actions')
                local enable_icons = ${toLua cfg.icons.enable}

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
                vim.keymap.set('n', '-', function()
                  vim.cmd.edit(vim.fn.expand('%:p:h'))
                end, { desc = "Files" })
              '';
          }
          {
            plugin = lualine-nvim;
            type = "lua";
            config = # lua
              ''
                local enable_icons = ${toLua cfg.icons.enable}
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
                    lualine_y = { "progress", mixed_indent },
                    lualine_z = { "location", trailing_whitespace },
                  },
                  options = {
                    icons_enabled = enable_icons,
                  },
                }
              '';
          }
          {
            plugin = nvim-surround;
            type = "lua";
            config = # lua
              ''
                require("nvim-surround").setup {}
              '';
          }
          {
            plugin = openingh-nvim;
            type = "lua";
            config = # lua
              ''
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
            config = # lua
              ''
                require("remember").setup {}
              '';
          }
          {
            plugin = tokyonight-nvim;
            type = "lua";
            config = # lua
              ''
                vim.cmd.colorscheme("tokyonight-moon")
              '';
          }
          # telescope
          {
            plugin = telescope-nvim;
            type = "lua";
            config = # lua
              ''
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
          {
            plugin = project-nvim;
            type = "lua";
            config = # lua
              ''
                require("project_nvim").setup {}
                vim.keymap.set('n', '<Leader>p', telescope.extensions.projects.projects, { desc = "Projects" })
              '';
          }
          telescope-fzf-native-nvim
          telescope-ui-select-nvim
          telescope-undo-nvim
          # END telescope
          {
            plugin = url-open;
            type = "lua";
            config = # lua
              ''
                require("url-open").setup {
                  open_only_when_cursor_on_url = false,
                  highlight_url = {
                    cursor_move = { enabled = false, }
                  }
                }
                vim.keymap.set("n", "gx", function()
                  vim.cmd("URLOpenUnderCursor")
                end , { desc = "Open URL under cursor" })
              '';
          }
          {
            plugin = vim-easy-align;
            type = "lua";
            config = # lua
              ''
                vim.keymap.set({'n', 'x'}, 'ga', '<Plug>(EasyAlign)', { remap = true, desc = "Align" })
              '';
          }
          {
            plugin = vim-test;
            type = "lua";
            config = # lua
              ''
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
            config = # lua
              ''
                vim.o.timeout = true
                vim.o.timeoutlen = 300
                require("which-key").setup {}
              '';
          }
          {
            plugin = whitespace-nvim;
            type = "lua";
            config = # lua
              ''
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
          lexima-vim
          mkdir-nvim
          vim-advanced-sorters
          vim-fugitive
        ]
        ++ lib.optionals cfg.markdownPreview.enable [
          {
            plugin = markdown-preview-nvim;
            type = "lua";
            config = # lua
              ''
                vim.keymap.set("n", "<Leader>P", "<Plug>MarkdownPreviewToggle", { desc = "Markdown Preview toggle" })
              '';
          }
        ]
        ++ lib.optionals cfg.cmp.enable [
          cmp-nvim-lsp
          cmp-path
          cmp-snippy
          {
            plugin = nvim-cmp;
            type = "lua";
            config = # lua
              ''
                local cmp = require("cmp")
                cmp.setup {
                  completion = {
                    autocomplete = false,
                    completeopt = vim.opt.completeopt._value,
                  },
                  mapping = {
                    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                    ['<C-f>'] = cmp.mapping.scroll_docs(4),
                    ['<C-k>'] = cmp.mapping.select_prev_item(),
                    ['<C-j>'] = cmp.mapping.select_next_item(),
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<C-e>'] = cmp.mapping.abort(),
                    ['<CR>'] = cmp.mapping.confirm({ select = true }),
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
                }
              '';
          }
          {
            plugin = nvim-snippy;
            type = "lua";
            config = # lua
              ''
                require("snippy").setup {}
                local mappings = require("snippy.mapping")

                vim.keymap.set('i', '<Tab>', mappings.expand_or_advance('<Tab>'), { desc = "Snippy expand or advance" })
                vim.keymap.set('s', '<Tab>', mappings.next('<Tab>'), { desc = "Snippy next" })
                vim.keymap.set({'i', 's'}, '<S-Tab>', mappings.previous('<S-Tab>'), { desc = "Snippy previous" })
                vim.keymap.set({'n', 'x'}, '<Leader>x', mappings.cut_text, { remap = true, desc = "Snippy delete" })
              '';
          }
        ]
        ++ lib.optionals cfg.lsp.enable [
          {
            plugin = nvim-lspconfig;
            type = "lua";
            config = # lua
              ''
                -- Setup language servers.
                -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
                local lspconfig = require("lspconfig")
                local capabilities = {}
                ${lib.optionalString cfg.cmp.enable # lua
                  ''
                    capabilities = require("cmp_nvim_lsp").default_capabilities()
                  ''
                }
                local servers = {
                  { "bashls" },
                  { "marksman" },
                  { "nil_ls",
                    opts = {
                      settings = {
                        ["nil"] = {
                          formatting = {
                            command = { "nixfmt" },
                          },
                          nix = {
                            flake = {
                              autoArchive = false,
                            },
                          },
                        },
                      },
                    },
                  },
                  { "nixd",
                    opts = {
                      settings = {
                        ["nixd"] = {
                          nixpkgs = {
                            expr = 'import "${flake.inputs.nixpkgs}" { }',
                          },
                          formatting = {
                            command = { "nixfmt" },
                          },
                          options = {
                            nixos = {
                              expr = '(let pkgs = import "${flake.inputs.nixpkgs}" { }; in (pkgs.lib.evalModules { modules =  (import "${flake.inputs.nixpkgs}/nixos/modules/module-list.nix") ++ [ ({...}: { nixpkgs.hostPlatform = builtins.currentSystem;} ) ] ; })).options',
                            },
                            home_manager = {
                              expr = '(let pkgs = import "${flake.inputs.nixpkgs}" { }; lib = import "${flake.inputs.home-manager}/modules/lib/stdlib-extended.nix" pkgs.lib; in (lib.evalModules { modules =  (import "${flake.inputs.home-manager}/modules/modules.nix") { inherit lib pkgs; check = false; }; })).options',
                            },
                          },
                          diagnostic = {
                            suppress = {
                              "sema-escaping-with"
                            },
                          },
                        },
                      },
                    },
                  },
                  { "clojure_lsp" },
                  { "gopls" },
                  { "pyright",
                    opts = {
                      settings = {
                        pyright = {
                          -- Using Ruff's import organizer
                            disableOrganizeImports = true,
                        },
                        python = {
                          analysis = {
                            -- Ignore all files for analysis to exclusively use Ruff for linting
                              ignore = { '*' },
                          },
                        },
                      },
                    },
                  },
                  { "ruff" },
                  { "cssls" },
                  { "eslint" },
                  { "html" },
                  { "jsonls" },
                }
                for _, server in pairs(servers) do
                  local config = lspconfig[server[1]]

                  if vim.fn.executable(config.document_config.default_config.cmd[1]) ~= 0 then
                    local shared_config = { capabilities = capabilities }

                    config.setup(vim.tbl_deep_extend("force", shared_config, server["opts"] or {}))
                  end
                end

                local builtin = require("telescope.builtin")

                -- Global mappings.
                -- See `:help vim.diagnostic.*` for documentation on any of the below functions
                vim.keymap.set('n', '<space>ld', builtin.diagnostics, { desc = "LSP diagnostics" })

                -- https://gist.github.com/RaafatTurki/64d89abf326e9fce6eb717f7c1f8a97e
                function LspRename()
                  local curr_name = vim.fn.expand("<cword>")
                  local value = vim.fn.input("LSP Rename: ", curr_name)
                  local lsp_params = vim.lsp.util.make_position_params()

                  if not value or #value == 0 or curr_name == value then return end

                  -- request lsp rename
                  lsp_params.newName = value
                  vim.lsp.buf_request(0, "textDocument/rename", lsp_params, function(_, res, ctx, _)
                    if not res then return end

                    -- apply renames
                    local client = vim.lsp.get_client_by_id(ctx.client_id)
                    vim.lsp.util.apply_workspace_edit(res, client.offset_encoding)

                    -- print renames
                    local changed_files_count = 0
                    local changed_instances_count = 0

                    if (res.documentChanges) then
                      for _, changed_file in pairs(res.documentChanges) do
                        changed_files_count = changed_files_count + 1
                        changed_instances_count = changed_instances_count + #changed_file.edits
                      end
                    elseif (res.changes) then
                      for _, changed_file in pairs(res.changes) do
                        changed_instances_count = changed_instances_count + #changed_file
                        changed_files_count = changed_files_count + 1
                      end
                    end

                    -- compose the right print message
                    print(string.format("renamed %s instance%s in %s file%s. %s",
                      changed_instances_count,
                      changed_instances_count == 1 and "" or "s",
                      changed_files_count,
                      changed_files_count == 1 and "" or "s",
                      changed_files_count > 1 and "To save them run ':wa'" or ""
                    ))
                  end)
                end

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
                    vim.keymap.set('n', '<Leader>lr', LspRename, { buffer = ev.buf, desc = "LSP rename" })
                    vim.keymap.set({'n', 'v'}, '<Leader>la', vim.lsp.buf.code_action, { buffer = ev.buf, desc = "LSP code action" })
                    vim.keymap.set('n', '<Leader>f', function()
                      vim.lsp.buf.format { async = true }
                    end, { buffer = ev.buf, desc = "LSP format" })
                  end,
                })
              '';
          }
        ]
        ++ lib.optionals cfg.treeSitter.enable [
          {
            plugin = nvim-ufo;
            type = "lua";
            config = # lua
              ''
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
            plugin = nvim-treesitter-textobjects;
            type = "lua";
            config = # lua
              ''
                local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

                -- vim way: ; goes to the direction you were moving.
                vim.keymap.set({"n", "x", "o"}, ";", ts_repeat_move.repeat_last_move)
                vim.keymap.set({"n", "x", "o"}, ",", ts_repeat_move.repeat_last_move_opposite)

                -- Optionally, make builtin f, F, t, T also repeatable with ; and ,
                vim.keymap.set({"n", "x", "o"}, "f", ts_repeat_move.builtin_f_expr, { expr = true })
                vim.keymap.set({"n", "x", "o"}, "F", ts_repeat_move.builtin_F_expr, { expr = true })
                vim.keymap.set({"n", "x", "o"}, "t", ts_repeat_move.builtin_t_expr, { expr = true })
                vim.keymap.set({"n", "x", "o"}, "T", ts_repeat_move.builtin_T_expr, { expr = true })

                -- will be set nvim-treesitter itself
                local textobjects_setup = {
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
                }
              '';
          }
          {
            plugin = nvim-treesitter.withAllGrammars;
            type = "lua";
            config = # lua
              ''
                require("nvim-treesitter.configs").setup {
                  highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
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
                    enable = false,
                  },
                  autotag = {
                    enable = true,
                  },
                  textobjects = textobjects_setup,
                }
              '';
          }
          nvim-ts-autotag
        ]
        ++ lib.optionals cfg.icons.enable [ nvim-web-devicons ];
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
      categories = [
        "Utility"
        "TextEditor"
      ];
    };
  };
}

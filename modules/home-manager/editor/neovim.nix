{
  config,
  pkgs,
  lib,
  flake,
  ...
}:

let
  enableIcons = config.home-manager.cli.icons.enable;
  toLua = lib.generators.toLua { };
  cfg = config.home-manager.editor.neovim;
in
{
  options.home-manager.editor.neovim = {
    enable = lib.mkEnableOption "Neovim config" // {
      default = config.home-manager.editor.enable;
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
      ++ lib.optionals enableIcons [
        config.theme.fonts.symbols.package
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

      extraLuaConfig = # lua
        ''
          -- general config
          vim.g.mapleader = ' '
          vim.g.maplocalleader = ','

          -- bytecompile lua modules
          vim.loader.enable()

          -- load .exrc, .nvimrc and .nvim.lua local files
          vim.opt.exrc = true

          -- highlight current line (enabled by mini.basics)
          vim.opt.cursorline = false

          -- copy and paste use the system clipboard
          vim.opt.clipboard:append { "unnamedplus" }

          -- show vertical colum
          vim.opt.colorcolumn:append { 81, 121 }

          -- avoid swapfile warning
          vim.opt.shortmess:append { A = true }

          -- disable "How to disable mouse" menu
          vim.cmd.aunmenu { [[PopUp.How-to\ disable\ mouse]] }
          vim.cmd.aunmenu { [[PopUp.-1-]] }

          -- make Esc enter Normal mode in Term
          vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]])
          vim.keymap.set('t', '<M-[>', [[<C-\><C-n>]])
          vim.keymap.set('t', '<C-v><Esc>', [[<C-\><C-n>]])
          vim.keymap.set('n', '<Leader>T', '<cmd>:terminal<CR>', { desc = "Terminal" })
          -- disable line numbers in terminal
          vim.api.nvim_create_autocmd({ "TermOpen" }, {
            command = "setlocal nonumber",
            pattern = { "*" },
          })

          -- unsets the 'last search pattern'
          vim.keymap.set('n', '<C-g>', '<cmd>:noh<CR>', { desc = "Clear highlight" })

          -- completion
          vim.keymap.set({'i', 'c'}, '<C-j>', function()
            return vim.fn.pumvisible() ~= 0 and '<C-n>' or '<C-j>'
          end, { expr = true })
          vim.keymap.set({'i', 'c'}, '<C-k>', function()
            return vim.fn.pumvisible() ~= 0 and '<C-p>' or '<C-k>'
          end, { expr = true })
          vim.keymap.set({'i', 'c'}, '<CR>', function()
            return vim.fn.pumvisible() ~= 0 and '<C-y>' or '<CR>'
          end, { expr = true })
          vim.keymap.set('i', '<C-Space>', '<C-x><C-o>')

          -- enable syntaxcomplete if omnifunc is unavailable
          vim.api.nvim_create_autocmd({ "FileType" }, {
            command = 'if &omnifunc == "" | setlocal omnifunc=syntaxcomplete#Complete | endif',
            pattern = { "*" },
          })

          -- reload file if changed
          vim.opt.autoread = true
          vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
            command = "if mode() != 'c' | checktime | endif",
            pattern = { "*" },
          })

          -- autoindent when starting a new line with 'o' or 'O'
          vim.opt.autoindent = true
          vim.opt.formatoptions:append { o = true, j = true }

          -- create an autocommand to enable spellcheck for specified file types
          vim.api.nvim_create_autocmd({ "FileType" }, {
            pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
            callback = function()
              vim.opt_local.spell = true
            end,
            desc = "Enable spellcheck for defined filetypes",
          })

          local function preview_markdown()
            local file = vim.fn.expand("%")
            local on_exit_cb = function(out)
              print("Markdown preview process exited with code:", out.code)
            end
            local process = vim.system(
              {"${lib.getExe pkgs.gh-gfm-preview}", file},
              on_exit_cb
            )

            vim.api.nvim_create_autocmd({ "BufUnload", "BufDelete" }, {
              buffer = vim.api.nvim_get_current_buf(),
              callback = function()
                process:kill("sigterm")
                -- timeout (in ms), will call KILL upon timeout
                process:wait(500)
              end,
            })
          end

          vim.api.nvim_create_autocmd({ "FileType" }, {
            pattern = { "markdown" },
            callback = function()
              vim.keymap.set("n", "<Leader>P", preview_markdown, {
                desc = "Markdown preview", buffer = true
              })
            end,
          })
        '';

      # To install non-packaged plugins, use
      # pkgs.vimUtils.buildVimPlugin { }
      plugins =
        with pkgs.vimPlugins;
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
            plugin = fzf-lua;
            type = "lua";
            config = # lua
              ''
                local enable_icons = ${toLua enableIcons}
                local fzf = require("fzf-lua")
                fzf.setup {
                  "telescope",
                  defaults = {
                    file_icons = enable_icons,
                    git_icons = enable_icons,
                  },
                  winopts = {
                    height = 0.4,
                    width = 1.0,
                    row = 1.0,
                  },
                  fzf_opts = {
                    ["--layout"] = "reverse",
                  },
                }

                vim.keymap.set("n", "<Leader><Leader>", fzf.files, { desc = "Find files" })
                vim.keymap.set("n", "<Leader>/", fzf.live_grep, { desc = "Live grep" })
                vim.keymap.set("n", "<Leader>*", fzf.grep_cword, { desc = "Grep word under cursor" })
                vim.keymap.set("n", "<Leader>b", fzf.buffers, { desc = "Buffers" })
                vim.keymap.set("n", "<Leader>c", fzf.commands, { desc = "Commands" })
                vim.keymap.set("n", "<Leader>gc", fzf.git_commits, { desc = "Git commits" })
                vim.keymap.set("n", "<Leader>gC", fzf.git_bcommits, { desc = "Git buffer commits" })
                vim.keymap.set("n", "<Leader>gb", fzf.git_branches, { desc = "Git branches" })
                vim.keymap.set("n", "<Leader>gs", fzf.git_status, { desc = "Git status" })
                vim.keymap.set("n", "<Leader>gS", fzf.git_stash, { desc = "Git stash" })
                vim.keymap.set("n", "z=", fzf.spell_suggest, { desc = "Spell suggest" })
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
            plugin = gx-nvim;
            type = "lua";
            config = # lua
              ''
                require("gx").setup {
                  handler_options = {
                    search_engine = "duckduckgo"
                  }
                }

                vim.keymap.set({"n", "x"}, "gx", "<CMD>Browse<CR>", { desc = "Open in Browse" })
              '';
          }
          {
            plugin = mini-nvim;
            type = "lua";
            config = # lua
              ''
                ${lib.optionalString enableIcons # lua
                  ''
                    local icons = require('mini.icons')
                    icons.setup {}
                    icons.mock_nvim_web_devicons()
                  ''
                }
                local enable_icons = ${toLua enableIcons}

                require('mini.ai').setup {
                  -- HACK: not recommended in docs so not sure if safe or not
                  n_lines = 10^3,
                }
                require('mini.align').setup {}
                require('mini.basics').setup {
                  mappings = {
                    windows = true,
                    move_with_alt = true,
                  },
                }
                require('mini.completion').setup {
                  delay = { completion = 10^7, info = 10^7, signature = 10^7 },
                  lsp_completion = { source_func = 'omnifunc' }
                }
                require('mini.diff').setup {}
                require('mini.git').setup {}
                require('mini.jump').setup {}
                require('mini.starter').setup {}
                require('mini.statusline').setup {
                  use_icons = enable_icons,
                }
                require('mini.tabline').setup {
                  show_icons = enable_icons,
                }
                -- mini.tabline sets showtabline = 2, always showing tabline
                -- I prefer to only have it if we have more than one tab
                vim.opt.showtabline = 1

                require('mini.surround').setup {
                  mappings = {
                    add = "ys",
                    delete = "ds",
                    find = "",
                    find_left = "",
                    highlight = "",
                    replace = "cs",
                    update_n_lines = "",

                    -- Add this only if you don't want to use extended mappings
                    suffix_last = "",
                    suffix_next = "",
                  },
                  search_method = "cover_or_next",
                  -- HACK: not recommended in docs so not sure if safe or not
                  n_lines = 10^3,
                }
                -- Remap adding surrounding to Visual mode selection
                vim.keymap.del('x', 'ys')
                vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
                -- Make special mapping for "add surrounding for line"
                vim.keymap.set('n', 'yss', 'ys_', { remap = true })

                local miniclue = require('mini.clue')
                miniclue.setup {
                  triggers = {
                    -- Leader triggers
                    { mode = 'n', keys = '<Leader>' },
                    { mode = 'x', keys = '<Leader>' },

                    -- Built-in completion
                    { mode = 'i', keys = '<C-x>' },

                    -- `g` key
                    { mode = 'n', keys = 'g' },
                    { mode = 'x', keys = 'g' },

                    -- Marks
                    { mode = 'n', keys = "'" },
                    { mode = 'n', keys = '`' },
                    { mode = 'x', keys = "'" },
                    { mode = 'x', keys = '`' },

                    -- Registers
                    { mode = 'n', keys = '"' },
                    { mode = 'x', keys = '"' },
                    { mode = 'i', keys = '<C-r>' },
                    { mode = 'c', keys = '<C-r>' },

                    -- Window commands
                    { mode = 'n', keys = '<C-w>' },

                    -- `z` key
                    { mode = 'n', keys = 'z' },
                    { mode = 'x', keys = 'z' },
                  },

                  clues = {
                    miniclue.gen_clues.builtin_completion(),
                    miniclue.gen_clues.g(),
                    miniclue.gen_clues.marks(),
                    miniclue.gen_clues.registers(),
                    miniclue.gen_clues.windows(),
                    miniclue.gen_clues.z(),
                    { mode = 'n', keys = '<Leader>g', desc = '+Git' },
                    { mode = 'n', keys = '<Leader>l', desc = '+LSP' },
                    { mode = 'n', keys = '<Leader>t', desc = '+Test' },
                    { mode = 'n', keys = '<Leader>w', desc = '+Whitespace' },
                  },

                  window = {
                    config = {
                      width = 'auto',
                    },
                    delay = 300,
                  },
                }

                local hi_words = require('mini.extra').gen_highlighter.words
                local hipatterns = require('mini.hipatterns')
                hipatterns.setup {
                  highlighters = {
                    fixme = hi_words({ 'FIXME' }, 'MiniHipatternsFixme'),
                    hack = hi_words({ 'HACK' }, 'MiniHipatternsHack'),
                    todo = hi_words({ 'TODO' }, 'MiniHipatternsTodo'),
                    note = hi_words({ 'TODO' }, 'MiniHipatternsNote'),
                    xxx = hi_words({ 'XXX' }, 'MiniHipatternsFixme'),
                    -- Highlight hex color strings (`#rrggbb`) using that color
                    hex_color = hipatterns.gen_highlighter.hex_color(),
                  },
                }

                local trailspace = require('mini.trailspace')
                trailspace.setup {}
                vim.keymap.set('n', '<Leader>ww', trailspace.trim, { desc = "Trim whitespace" })
                vim.keymap.set('n', '<Leader>wl', trailspace.trim_last_lines, { desc = "Trim last lines" })
              '';
          }
          {
            plugin = neogit;
            type = "lua";
            config = # lua
              ''
                local neogit = require('neogit')
                neogit.setup {}
                vim.keymap.set("n", "<Leader>gg", neogit.open, { desc = "Neogit" })
              '';
          }
          {
            plugin = neotest;
            type = "lua";
            config = # lua
              ''
                local neotest = require("neotest")

                neotest.setup {
                  adapters = {
                    require("neotest-go") {},
                    require("neotest-python") {},
                  },
                }

                vim.keymap.set("n", "<Leader>tt", neotest.run.run, { desc = "Test nearest" })
                vim.keymap.set("n", "<Leader>ta", neotest.run.attach, { desc = "Attach nearest" })
                vim.keymap.set("n", "<Leader>ts", neotest.run.stop, { desc = "Stop test" })
                vim.keymap.set("n", "<Leader>tT", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Test file" })
              '';
          }
          neotest-python
          neotest-go
          {
            plugin = oil-nvim;
            type = "lua";
            config = # lua
              ''
                local oil = require("oil")
                oil.setup {
                  columns = {
                    ${lib.optionalString enableIcons (toLua "icons")}
                  },
                  skip_confirm_for_simple_edits = true,
                  constrain_cursor = "name",
                  watch_for_changes = true,
                  lsp_file_methods = {
                    autosave_changes = true,
                  },
                }

                vim.keymap.set("n", "-", oil.open, { desc = "Open parent directory" })
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
          lexima-vim
          mkdir-nvim
          vim-advanced-sorters
          vim-nix
        ]
        ++ lib.optionals config.home-manager.desktop.kitty.enable [
          {
            plugin = kitty-scrollback-nvim;
            type = "lua";
            config = # lua
              ''
                require("kitty-scrollback").setup {
                  status_window = {
                    autoclose = true,
                    show_timer = true,
                  },
                }
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
                -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md
                local lspconfig = require("lspconfig")
                local servers_configs = {
                  { "bashls" },
                  { "clojure_lsp" },
                  { "cssls" },
                  { "eslint" },
                  { "gopls" },
                  { "html" },
                  { "jsonls" },
                  { "lua_ls" },
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
                          formatting = {
                            command = { "nixfmt" },
                          },
                          options = {
                            nixos = {
                              expr = [[
                                (let
                                  pkgs = import "${flake.inputs.nixpkgs}" { };
                                  inherit (pkgs) lib;
                                in (lib.evalModules {
                                  modules = (import "${flake.inputs.nixpkgs}/nixos/modules/module-list.nix");
                                  check = false;
                                })).options
                              ]],
                            },
                            nix_darwin = {
                              expr = [[
                                (let
                                  pkgs = import "${flake.inputs.nixpkgs}" { };
                                  inherit (pkgs) lib;
                                in (lib.evalModules {
                                  modules = (import "${flake.inputs.nix-darwin}/modules/module-list.nix");
                                  check = false;
                                })).options
                              ]],
                            },
                            home_manager = {
                              expr = [[
                                (let
                                  pkgs = import "${flake.inputs.nixpkgs}" { };
                                  lib = import "${flake.inputs.home-manager}/modules/lib/stdlib-extended.nix" pkgs.lib;
                                in (lib.evalModules {
                                  modules =  (import "${flake.inputs.home-manager}/modules/modules.nix") {
                                    inherit lib pkgs;
                                    check = false;
                                  };
                                })).options
                              ]],
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
                }

                -- for future use
                -- lspconfig.util.default_config = {}
                for _, server in pairs(servers_configs) do
                  local config = lspconfig[server[1]]

                  if vim.fn.executable(config.document_config.default_config.cmd[1]) ~= 0 then
                    config.setup(server["opts"] or {})
                  end
                end

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

                local fzf = require("fzf-lua")
                -- Use LspAttach autocommand to only map the following keys
                -- after the language server attaches to the current buffer
                vim.api.nvim_create_autocmd("LspAttach", {
                  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                  callback = function(ev)
                    -- Buffer local mappings.
                    -- See `:help vim.lsp.*` for documentation on any of the below functions
                    -- or fzf-lua documentation
                    vim.keymap.set("n", "gD", fzf.lsp_references, { desc = "LSP references" })
                    vim.keymap.set("n", "gd", fzf.lsp_definitions, { desc = "LSP definitions" })
                    vim.keymap.set("n", "gi", fzf.lsp_implementations, { desc = "LSP implementations" })
                    vim.keymap.set("n", "<Leader>ld", fzf.diagnostics_document, { desc = "LSP document diagnostics" })
                    vim.keymap.set("n", "<Leader>ls", fzf.lsp_document_symbols, { desc = "LSP document symbols" })
                    vim.keymap.set("n", "<Leader>lt", fzf.lsp_typedefs, { desc = "LSP type definitions" })
                    vim.keymap.set("n", "<Leader>lr", LspRename, { desc = "LSP rename" })
                    vim.keymap.set("n", "<Leader>lf", function() vim.lsp.buf.format { async = true } end, { desc = "LSP format" })
                    vim.keymap.set("n", "<Leader>la", fzf.lsp_code_actions, { desc = "LSP code action" })
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

                vim.keymap.set('n', 'zR', ufo.openAllFolds, { desc = "Open all folds" })
                vim.keymap.set('n', 'zM', ufo.closeAllFolds, { desc = "Close all folds" })
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
            config = # lua
              ''
                require("nvim-treesitter.configs").setup {
                  highlight = {
                    enable = true,
                  },
                  incremental_selection = {
                    enable = true,
                    keymaps = {
                      init_selection = "gnn",
                      node_incremental = "grn",
                      scope_incremental = "grc",
                      node_decremental = "grm",
                    },
                  },
                  indent = {
                    enable = false,
                  },
                }
              '';
          }
          {
            plugin = nvim-ts-autotag;
            type = "lua";
            config = # lua
              ''
                require("nvim-ts-autotag").setup {}
              '';
          }
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
      categories = [
        "Utility"
        "TextEditor"
      ];
    };
  };
}

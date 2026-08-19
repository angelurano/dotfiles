return {
  -- LAZYDEV: Configure Lua LS for Neovim config and plugin APIs
  {
    "folke/lazydev.nvim",
    ft = "lua", -- Only load lazydev for Lua files
    opts = {
      library = {
        -- Load luvit types for vim.uv
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- 1. BLINK.CMP: Asynchronous completion engine
  {
    'saghen/blink.cmp',
    lazy = true,
    version = '*',
    dependencies = {
      'rafamadriz/friendly-snippets',
    },
    opts = {
      keymap = {
        preset = 'super-tab',
        ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      },
      completion = {
        menu = {
          border = 'rounded',
        },
        list = {
          selection = {
            preselect = true,
            auto_insert = false,
          },
        },
        documentation = {
          auto_show = false, -- <C-leader> to show
          window = {
            border = 'rounded',
            max_width = 100,
            max_height = 30,
          },
        },
      },
      signature = {
        enabled = true,
        window = {
          border = 'rounded',
        },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
    },
  },

  -- 2. NVIM-LSPCONFIG: LSP configuration coordinator (adapted to Neovim Core)
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- Step A: Initialize Mason
      require("mason").setup({
        ui = { border = "rounded" },
      })

      -- System and OS Environment Detection
      local has_nix = vim.fn.executable("nix") == 1
      local is_win = vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1
      local is_linux = not is_win
      local has_node = vim.fn.executable("node") == 1 or vim.fn.executable("bun") == 1 or has_nix
      local has_python = vim.fn.executable("python") == 1 or vim.fn.executable("python3") == 1 or has_nix

      -- Base servers map
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } }, -- Prevent global variable warnings for 'vim'
            },
          },
        },
        clangd = {
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=never",
            "--completion-style=detailed",
            "--offset-encoding=utf-16",
          },
        }, -- C / C++
        marksman = {
          filetypes = { "markdown" },
          env = {
            DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1",
          },
        },          -- Markdown LSP
        taplo = {}, -- TOML LSP (Rust binary)
        biome = {}, -- JS/TS/JSON fast linter & formatter (Rust binary)
      }

      -- Node.js / Bun dependent servers
      if has_node then
        local mason_tsdk = vim.fn.stdpath("data") ..
            "/mason/packages/typescript-language-server/node_modules/typescript/lib"
        local fs = vim.uv or vim.loop
        local has_mason_tsdk = fs.fs_stat(mason_tsdk) ~= nil

        servers.ts_ls = {
          init_options = {
            hostInfo = "neovim",
            typescript = {
              tsdk = has_mason_tsdk and mason_tsdk or nil,
            },
          },
          root_dir = function(filename, _)
            local util = require("lspconfig.util")
            return util.root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git")(filename)
          end,
        }
        servers.eslint = {} -- ESLint for JavaScript / TypeScript
        servers.yamlls = {
          filetypes = { "yaml" },
          settings = {
            yaml = {
              telemetry = { enabled = false },
            },
          },
        }
        servers.dockerls = {}
        servers.jsonls = {}

        -- Shell Scripting LSP (Linux / Unix only)
        if is_linux then
          servers.bashls = {
            filetypes = { "sh", "bash", "zsh" },
          }
        end
      end

      -- Python LSP
      if has_python then
        servers.basedpyright = {}
      end

      -- PowerShell LSP (Windows only)
      if is_win then
        servers.powershell_es = {}
      end

      -- Nix LSP only on Nix systems
      if has_nix then
        servers.nil_ls = {
          settings = {
            formatting = {
              command = { "nixfmt" },
            },
          }
        }
      end

      -- Dynamically extract server names for Mason, excluding Nix-managed servers on Nix systems
      local ensure_installed = {}
      for _, name in ipairs(vim.tbl_keys(servers)) do
        local is_nix_managed = has_nix and (name == "nil_ls" or name == "clangd")
        if not is_nix_managed then
          table.insert(ensure_installed, name)
        end
      end

      -- Step C: Initialize mason-lspconfig with the server list
      require("mason-lspconfig").setup({
        ensure_installed = ensure_installed,
      })

      -- Step D: Retrieve LSP capabilities from blink.cmp
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Global diagnostics styling and behavior
      vim.diagnostic.config({
        virtual_text = { prefix = "●" },
        severity_sort = true,
        float = { border = "rounded" },
      })

      -- Cache snacks module reference once for LspAttach callback
      local snacks_ok, snacks = pcall(require, "snacks")

      -- Keymaps enabled only when LSP attaches
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(event)
          local bufnr = event.buf
          local buftype = vim.bo[bufnr].buftype
          local bufname = vim.api.nvim_buf_get_name(bufnr)
          local is_file = buftype == "" and (bufname == "" or bufname:match("^/") or bufname:match("^[a-zA-Z]:"))
          if not is_file then
            local client_id = event.data.client_id
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(bufnr) then
                vim.lsp.buf_detach_client(bufnr, client_id)
              end
            end)
            return
          end

          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = desc })
          end

          map('gd', vim.lsp.buf.definition, 'Go to Definition')
          if snacks_ok and snacks.picker then
            map('gr', function() snacks.picker.lsp_references() end, 'Go to References')
            map('gI', function() snacks.picker.lsp_implementations() end, 'Go to Implementation')
            map('<leader>ds', function() snacks.picker.lsp_symbols() end, 'Document Symbols')
          else
            map('gr', vim.lsp.buf.references, 'Go to References')
            map('gI', vim.lsp.buf.implementation, 'Go to Implementation')
          end
          map('K', function() vim.lsp.buf.hover({ border = 'rounded' }) end, 'Hover Documentation')
          map('<leader>rn', vim.lsp.buf.rename, 'Rename Variable')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
          map('<leader>d', vim.diagnostic.open_float, 'Show Line Diagnostics')
        end,
      })

      -- Step E: Modern native configuration (replaces require('lspconfig')[...].setup)
      -- Iterate through the servers and use native Neovim APIs
      for server_name, server_opts in pairs(servers) do
        server_opts.capabilities = vim.tbl_deep_extend("force", capabilities, server_opts.capabilities or {})

        -- 1. Register/extend server configuration in the native Neovim API
        vim.lsp.config(server_name, server_opts)
        -- 2. Enable the server natively in the editor core
        vim.lsp.enable(server_name)
      end
    end,
  },

  -- 3. CONFORM.NVIM: Code formatter
  {
    'stevearc/conform.nvim',
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>F",
        function() require("conform").format({ async = true, lsp_fallback = true }) end,
        mode = "",
        desc = "Format buffer manual",
      },
    },
    opts = function()
      local has_nix = vim.fn.executable("nix") == 1
      local has_node = vim.fn.executable("node") == 1 or vim.fn.executable("bun") == 1 or has_nix
      local has_python = vim.fn.executable("python") == 1 or vim.fn.executable("python3") == 1 or has_nix

      local formatters = {
        lua = { "stylua" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        nix = { "nixfmt" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
      }

      -- Ruff format for Python (falls back to black if ruff is not installed)
      if has_python then
        formatters.python = { "ruff_format", "black", stop_after_first = true }
      end

      -- Prettier requires Node.js or Bun to run
      if has_node then
        formatters.javascript = { "prettier" }
        formatters.typescript = { "prettier" }
        formatters.astro = { "prettier" }
      end

      return {
        formatters_by_ft = formatters,
      }
    end,
  },

  -- 4. DIRENV: Environment auto-reloading (Devenv integration)
  {
    "direnv/direnv.vim",
    lazy = false,
    cond = function()
      return vim.fn.executable("direnv") == 1
    end,
    init = function()
      vim.g.direnv_silent_load = 1
    end,
    config = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "DirenvLoaded",
        callback = function()
          vim.schedule(function()
            -- Re-trigger FileType to start LSP clients that weren't executable on startup
            vim.api.nvim_exec_autocmds("FileType", { buffer = 0 })
          end)
        end,
      })
    end,
  }
}

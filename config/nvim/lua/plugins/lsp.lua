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
        list = {
          selection = {
            preselect = true,
            auto_insert = false,
          },
        },
        documentation = {
          auto_show = false, -- <C-leader> to show
          window = {
            max_width = 100,
            max_height = 30,
          },
        },
      },
      signature = { enabled = true },
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

      -- Step B: Map of server configurations
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } }, -- Prevent global variable warnings for 'vim'
            },
          },
        },
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=never",
            "--completion-style=detailed",
          },
        }, -- C / C++
        marksman = {
          env = {
            DOTNET_SYSTEM_GLOBALIZATION_INVARIANT = "1",
          },
        }, -- Markdown LSP
        -- jdtls = {},  -- Java
      }

      local has_nix = vim.fn.executable("nix") == 1

      -- Check for Node.js or Bun executable availability, or if we are on a Nix system (since it can be loaded dynamically)
      if vim.fn.executable("node") == 1 or vim.fn.executable("bun") == 1 or has_nix then
        servers.ts_ls = {}  -- TypeScript / JavaScript
        servers.eslint = {} -- ESLint for JavaScript / TypeScript
      end

      -- Biome handles JS/TS linting and formatting (precompiled binary, no cargo or node required)
      servers.biome = {}

      -- Check for Python executable availability, or if we are on a Nix system
      if vim.fn.executable("python") == 1 or vim.fn.executable("python3") == 1 or has_nix then
        servers.basedpyright = {} -- Python LSP
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

      -- Keymaps enabled only when LSP attaches
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = desc })
          end

          local ok, snacks = pcall(require, "snacks")

          map('gd', vim.lsp.buf.definition, 'Go to Definition')
          if ok and snacks.picker then
            map('gr', function() snacks.picker.lsp_references() end, 'Go to References')
            map('gI', function() snacks.picker.lsp_implementations() end, 'Go to Implementation')
            map('<leader>ds', function() snacks.picker.lsp_symbols() end, 'Document Symbols')
          else
            map('gr', vim.lsp.buf.references, 'Go to References')
            map('gI', vim.lsp.buf.implementation, 'Go to Implementation')
          end
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
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
    -- event = { "BufWritePre" }, -- disabled
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
      local formatters = {
        lua = { "stylua" },
        python = { "black" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        nix = { "nixfmt" },
      }
      -- Prettier requires Node.js or Bun to run
      if vim.fn.executable("node") == 1 or vim.fn.executable("bun") == 1 then
        formatters.javascript = { "prettier" }
        formatters.typescript = { "prettier" }
      end
      return {
        formatters_by_ft = formatters,
      }
    end,
  },

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
            pcall(function()
              vim.cmd("lsp restart")
            end)
          end)
        end,
      })
    end,
  }
}

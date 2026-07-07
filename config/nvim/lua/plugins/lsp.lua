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
      vim.defer_fn(function()
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
          -- jdtls = {},  -- Java (Spring Boot)
        }

        -- Check for Node.js or Bun executable availability (required by ts_ls and eslint)
        if vim.fn.executable("node") == 1 or vim.fn.executable("bun") == 1 then
          servers.ts_ls = {}  -- TypeScript / JavaScript
          servers.eslint = {} -- ESLint for JavaScript / TypeScript
        end

        -- Biome handles JS/TS linting and formatting (precompiled binary, no cargo or node required)
        servers.biome = {}

        -- Check for Python executable availability
        if vim.fn.executable("python") == 1 or vim.fn.executable("python3") == 1 then
          servers.basedpyright = {}
        end

        -- Dynamically extract server names for Mason
        local ensure_installed = vim.tbl_keys(servers)

        -- Step C: Initialize mason-lspconfig with the server list

        require("mason-lspconfig").setup({
          ensure_installed = ensure_installed,
        })

        if vim.fn.executable("nil") == 1 then
          servers.nil_ls = {
            settings = {
              formatting = {
                command = { "nixfmt" },
              },
            }
          }
        end

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

            map('gd', vim.lsp.buf.definition, 'Go to Definition')
            map('gr', vim.lsp.buf.references, 'Go to References')
            map('K', vim.lsp.buf.hover, 'Hover Documentation')
            map('<leader>rn', vim.lsp.buf.rename, 'Rename Variable')
            map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
            map('<leader>d', vim.diagnostic.open_float, 'Show Line Diagnostics')
          end,
        })

        -- Step E: Modern native configuration (replaces require('lspconfig')[...].setup)
        -- Iterate through the servers and use native Neovim APIs
        for server_name, server_opts in pairs(servers) do
          server_opts.capabilities = capabilities

          -- 1. Register/extend server configuration in the native Neovim API
          vim.lsp.config(server_name, server_opts)
          -- 2. Enable the server natively in the editor core
          vim.lsp.enable(server_name)
        end
      end, 100)
    end,
  },

  -- 3. CONFORM.NVIM: Code formatter
  {
    'stevearc/conform.nvim',
    -- event = { "BufWritePre" }, -- disabled
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>f",
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
}

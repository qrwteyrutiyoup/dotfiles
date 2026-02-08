-- ============================================================================
-- Neovim Configuration with Native LSP
-- Languages: Python, Go, Rust, Bash, C/C++
-- ============================================================================

-- ============================================================================
-- Basic Settings
-- ============================================================================
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.mouse = 'a'
vim.opt.cursorline = true
vim.opt.history = 10000
vim.opt.clipboard = 'unnamedplus'
vim.opt.wrapmargin = 8

-- Indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.smarttab = true
vim.opt.expandtab = true
vim.opt.listchars = { tab = '  ', trail = '.' }

-- Disable backup files
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.swapfile = false

-- Color scheme
vim.opt.termguicolors = true
vim.opt.background = 'dark'

-- ============================================================================
-- Bootstrap lazy.nvim (plugin manager)
-- ============================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================================================
-- Plugin Setup
-- ============================================================================
require("lazy").setup({
  -- Essential plugins
  'tpope/vim-sensible',
  'tpope/vim-surround',
  'tpope/vim-commentary',
  'tpope/vim-fugitive',

  -- Color schemes
  'rafi/awesome-vim-colorschemes',

  -- Status line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup({
        options = {
          theme = 'auto',
          icons_enabled = true,
        }
      })
    end
  },

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        window = {
          position = "left",
          width = 30,
        }
      })
    end
  },

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('telescope').setup{}
    end
  },

  -- Treesitter for better syntax highlighting
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = { "python", "go", "rust", "bash", "c", "cpp", "lua", "vim" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },

  -- Mason: LSP server installer
  {
    'williamboman/mason.nvim',
    config = function()
      require("mason").setup()
    end
  },

  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "pyright",           -- Python
          "gopls",             -- Go
          "bashls",            -- Bash
          "clangd",            -- C/C++
        },
        automatic_installation = true,
        handlers = {
          -- Default handler for all servers
          function(server_name)
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            require('lspconfig')[server_name].setup({
              capabilities = capabilities,
            })
          end,
          -- Rust-analyzer (optional)
          ["rust_analyzer"] = function()
            local capabilities = require('cmp_nvim_lsp').default_capabilities()
            pcall(function()
              require('lspconfig').rust_analyzer.setup({
                capabilities = capabilities,
                settings = {
                  ['rust-analyzer'] = {
                    checkOnSave = {
                      command = "clippy"
                    },
                  },
                },
              })
            end)
          end,
        }
      })

      -- LSP keybindings
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspConfig', {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
          vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
          vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
          vim.keymap.set('n', '<leader>f', function()
            vim.lsp.buf.format { async = true }
          end, opts)
        end,
      })
    end
  },

  -- Keep lspconfig for mason-lspconfig compatibility
  'neovim/nvim-lspconfig',

  -- Completion
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
          { name = 'buffer' },
          { name = 'path' },
        })
      })
    end
  },

  -- Language-specific plugins
  {
    'fatih/vim-go',
    ft = 'go',
    build = ':GoUpdateBinaries',
    config = function()
      vim.g.go_highlight_build_constraints = 1
      vim.g.go_highlight_extra_types = 1
      vim.g.go_highlight_fields = 1
      vim.g.go_highlight_functions = 1
      vim.g.go_highlight_methods = 1
      vim.g.go_highlight_operators = 1
      vim.g.go_highlight_structs = 1
      vim.g.go_highlight_types = 1
      vim.g.go_fmt_command = "goimports"
    end
  },

  {
    'rust-lang/rust.vim',
    ft = 'rust',
    config = function()
      vim.g.rustfmt_autosave = 1
    end
  },
})

-- ============================================================================
-- Keybindings
-- ============================================================================

-- Leader key
vim.g.mapleader = ' '

-- File explorer
vim.keymap.set('n', '<C-n>', ':Neotree toggle<CR>', { silent = true })

-- Telescope (fuzzy finder)
vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>', { silent = true })
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>', { silent = true })
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>', { silent = true })

-- Window navigation (tmux-aware if in tmux)
if vim.env.TMUX then
  -- Tmux integration - seamless navigation between vim and tmux splits
  local function tmux_navigate(direction)
    local tmux_dir = ({h = 'L', j = 'D', k = 'U', l = 'R'})[direction]
    local win_before = vim.fn.winnr()
    vim.cmd('wincmd ' .. direction)
    local win_after = vim.fn.winnr()

    if win_before == win_after then
      vim.fn.system('tmux select-pane -' .. tmux_dir)
    end
  end

  vim.keymap.set('n', '<C-h>', function() tmux_navigate('h') end, { silent = true })
  vim.keymap.set('n', '<C-j>', function() tmux_navigate('j') end, { silent = true })
  vim.keymap.set('n', '<C-k>', function() tmux_navigate('k') end, { silent = true })
  vim.keymap.set('n', '<C-l>', function() tmux_navigate('l') end, { silent = true })
else
  vim.keymap.set('n', '<C-h>', '<C-w>h')
  vim.keymap.set('n', '<C-j>', '<C-w>j')
  vim.keymap.set('n', '<C-k>', '<C-w>k')
  vim.keymap.set('n', '<C-l>', '<C-w>l')
end

-- ============================================================================
-- Commands
-- ============================================================================

-- Strip trailing whitespace
vim.api.nvim_create_user_command('Strip', function()
  local save_cursor = vim.fn.getpos('.')
  vim.cmd([[%s/\s\+$//e]])
  vim.fn.setpos('.', save_cursor)
end, {})

-- ============================================================================
-- Autocommands
-- ============================================================================

-- Highlight trailing whitespace
vim.api.nvim_create_autocmd({"BufWinEnter"}, {
  pattern = {"*"},
  callback = function()
    vim.cmd([[match ExtraWhitespace /\s\+$/]])
  end
})

vim.api.nvim_set_hl(0, 'ExtraWhitespace', { bg = 'darkred' })

-- Filetype settings
vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = {"*.pro", "*.pri"},
  callback = function()
    vim.bo.filetype = "qmake"
  end
})

vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
  pattern = {"*.qml", "*.qmlproject"},
  callback = function()
    vim.bo.filetype = "qml"
  end
})

-- ============================================================================
-- Color Scheme
-- ============================================================================
vim.cmd([[
  try
    colorscheme termschool
  catch
    colorscheme default
  endtry
]])

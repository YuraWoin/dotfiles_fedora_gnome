-- 1. Базові налаштування (Рядки НЕ ПЛАВАЮТЬ)
vim.deprecate = function() end
vim.g.mapleader = " "
local opt = vim.opt
opt.number = true
opt.relativenumber = false 
opt.termguicolors = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.laststatus = 0
opt.shm:append("I")

-- 2. Встановлення Lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- 3. Налаштування плагінів (Безпечний метод)
require("lazy").setup({
  -- Колірна схема
  { "folke/tokyonight.nvim", lazy = false, priority = 1000, 
    config = function()
      require("tokyonight").setup({ transparent = true })
      vim.cmd[[colorscheme tokyonight]]
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
    end 
  },

  -- Підсвітка (Treesitter)
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

  -- Інтелект (LSP + Mason)
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim", config = true },

  -- Автодоповнення
  { "hrsh7th/nvim-cmp", 
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local cmp = require('cmp')
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        sources = { { name = 'nvim_lsp' } }
      })
    end
  },

  -- Термінал
  { "akinsho/toggleterm.nvim", version = "*", config = true },
})

-- 4. ФІКС ДЛЯ РЯДКІВ 65-68 (LSP та Treesitter)
-- Ми обгортаємо запуск у pcall, щоб Neovim не падав, якщо плагін ще не готовий

-- Налаштування Python
local lsp_status, lspconfig = pcall(require, "lspconfig")
if lsp_status then
  -- Використовуємо прямий запуск, щоб уникнути помилки deprecated
  --lspconfig.pyright.setup({})
  --
  require('lspconfig').pyright.setup({})
  --
end

-- Налаштування підсвітки
local ts_status, ts_configs = pcall(require, "nvim-treesitter.configs")
if ts_status then
  ts_configs.setup({
    ensure_installed = { "python", "lua" },
    highlight = { enable = true },
  })
end


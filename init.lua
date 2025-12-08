-- init.lua (modernized Neovim config)
-- Plugins: packer.nvim bootstrap + plugin list
-- Lualine used for statusline; Comment.nvim replaces NERDCommenter; treesitter replaces indentpython.vim

-- To install:
-- mkdir ~/.config/nvim
-- cp init.lua ~/.config/nvim/init.lu
-- Then open nvim and run :PackerSync
-- To test for errors:
-- nvim --clean -c 'luafile ~/.config/nvim/init.lua' -c quit

-- Disable deprecation warnings
vim.deprecate = function() end

-- Bootstrap packer if missing
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  print("Installing packer...")
  fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
end

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'editorconfig/editorconfig-vim'
  use 'nvim-treesitter/nvim-treesitter'
  use 'neovim/nvim-lspconfig'
  use 'mfussenegger/nvim-lint'
  use 'nvim-telescope/telescope.nvim'
  use {'nvim-lua/plenary.nvim'}
  use 'nvim-lualine/lualine.nvim'
  use 'numToStr/Comment.nvim'
  use 'catppuccin/nvim'
  use "williamboman/mason.nvim"
  use "williamboman/mason-lspconfig.nvim"
  use {
    'nvimtools/none-ls.nvim',
    config = function()
      local none_ls = require("null-ls")

      none_ls.setup({
        sources = {
          -- Python (Ruff recommended)
          none_ls.builtins.diagnostics.ruff:with({
            args = { "--ignore", "E501" }
          }),
          none_ls.builtins.formatting.ruff,

          -- Optional Python tools
          none_ls.builtins.formatting.black,
          none_ls.builtins.formatting.isort,

          -- Lua
          none_ls.builtins.formatting.stylua,

          -- Shell (Corrected configuration with filetype limit)
          none_ls.builtins.diagnostics.shellcheck:with({
            filetypes = { "sh", "bash", "zsh", "fish" }
          }),
          none_ls.builtins.formatting.shfmt,
        },
      })
    end
  }
  -- The closing 'end)' for the function and the 'startup' call
end)

-- Basic options (preserve from your .vimrc)
vim.o.encoding = 'utf-8'         -- set encoding
vim.wo.number = true             -- line numbers
vim.o.ruler = true               -- ruler
vim.o.showmatch = true           -- show matching paren
vim.o.autoindent = true
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2

-- Filetype/indent (kept)
vim.cmd('filetype plugin indent on')

-- Colorscheme and comment highlight (example)
vim.cmd('colorscheme catppuccin')  -- change to your preferred maintained theme
-- if you want comments blue like before, add:
-- vim.api.nvim_set_hl(0, "Comment", {fg = "#5f87ff"})  -- optional

-- Treesitter setup (gives better Python highlighting & indentation)
require('nvim-treesitter.configs').setup {
  ensure_installed = { "python", "javascript", "json", "lua" },
  highlight = { enable = true },
  indent = { enable = true },
}

-- LSP config (python example with pyright) + null-ls for flake8
local lspconfig = require('lspconfig')
lspconfig.pyright.setup({})

-- nvim-lint setup for on-save linting if you want (optional)
require('lint').linters_by_ft = {
  python = {'flake8'},
}

-- Auto-show diagnostic float on CursorHold
vim.o.updatetime = 300
vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
  callback = function()
    local opts = {
      focusable = false,
      close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
      scope = "cursor",
      source = "if_many",
    }
    vim.diagnostic.open_float(nil, opts)
  end,
})

vim.cmd [[
  augroup LintOnSave
    autocmd!
    autocmd BufWritePost *.py lua require('lint').try_lint()
  augroup END
]]

-- Comment.nvim setup (replaces NERDCommenter)
require('Comment').setup({
  -- Add mappings and options here; defaults are good and map to your common behavior
  padding = true,       -- Add a space after comment delimiters — similar to NERDSpaceDelims
  sticky = true,
})

-- Telescope basic mapping (fuzzy finder in place of ctrlp)
vim.api.nvim_set_keymap('n', '<Leader>p', "<cmd>lua require('telescope.builtin').find_files()<CR>", { noremap=true, silent=true })
vim.api.nvim_set_keymap('n', '<Leader>g', "<cmd>lua require('telescope.builtin').live_grep()<CR>", { noremap=true, silent=true })

-- Diagnostics signs (analogous to syntastic signs)
vim.fn.sign_define("DiagnosticSignError", {text = "", texthl = "DiagnosticSignError"})
vim.fn.sign_define("DiagnosticSignWarn",  {text = "", texthl = "DiagnosticSignWarn"})
vim.fn.sign_define("DiagnosticSignInfo",  {text = "", texthl = "DiagnosticSignInfo"})
vim.fn.sign_define("DiagnosticSignHint",  {text = "", texthl = "DiagnosticSignHint"})

-- Preserve trimming trailing whitespace on save (autocmd)
vim.cmd([[
augroup TrimWhitespace
  autocmd!
  autocmd BufWritePre * %s/\s\+$//e
augroup END
]])

-- Restore last cursor position on file open (preserve same behaviour)
vim.cmd([[
augroup RestoreCursor
  autocmd!
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g'\"" |
    \ endif
augroup END
]])

-- Reproduce your custom statusline using lualine:
-- Original had file path, flags (%w%h%m%r) and SyntasticStatuslineFlag() indicator,
-- and right aligned line/column & percent info.
local lualine = require('lualine')

local function syntastic_like()
  -- Use diagnostics to indicate presence of issues like SyntasticStatuslineFlag
  local diag = vim.diagnostic.get(0)
  if #diag == 0 then
    return 'OK'
  else
    return 'DIAG:'..#diag
  end
end

lualine.setup {
  options = {
    theme = 'auto',
    component_separators = '|',
    section_separators = '',
    globalstatus = false,
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {{'filename', path = 1}},  -- similar to %<%f
    lualine_c = {'branch'},
    lualine_x = {
      -- flags similar to %w%h%m%r could be handled by builtin components:
      function() -- emulate %w%h%m%r flags where feasible
        local flags = {}
        if vim.bo.modified then table.insert(flags, 'MOD') end
        if vim.o.filetype == '' then table.insert(flags, 'noft') end
        -- Add additional flags if you used them; keep minimal
        return table.concat(flags, ' ')
      end,
      syntastic_like,                           -- diagnostics indicator (replaces SyntasticStatuslineFlag)
      'encoding',
      'fileformat',
      'filetype'
    },
    lualine_y = {'progress'},
    lualine_z = {'location'},
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {'filename'},
    lualine_c = {},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
}

-- Optional: set python3 host program if you want to force a sys python
-- vim.g.python3_host_prog = '/usr/bin/python3'

-- End of init.lua

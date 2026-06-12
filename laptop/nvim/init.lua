-- Check if running in VSCode
local vscode = vim.g.vscode

-- General options that work in both environments
vim.opt.clipboard = 'unnamedplus'
vim.opt.relativenumber = true

-- VSCode-specific settings
if vscode then
  -- Basic options for VSCode
  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 2
  vim.opt.expandtab = true

  -- Essential keybindings for VSCode
  local opts = { noremap = true, silent = true }

  vim.keymap.set('n', '<C-h>', function()
    vim.fn.VSCodeNotify('workbench.action.navigateLeft')
  end, opts)

  vim.keymap.set('n', '<C-j>', function()
    vim.fn.VSCodeNotify('workbench.action.navigateDown')
  end, opts)

  vim.keymap.set('n', '<C-k>', function()
    vim.fn.VSCodeNotify('workbench.action.navigateUp')
  end, opts)

  vim.keymap.set('n', '<C-l>', function()
    vim.fn.VSCodeNotify('workbench.action.navigateRight')
  end, opts)

  -- VSCode-specific commands using vim.fn.VSCodeNotify
  vim.keymap.set('n', '\\f', function()
    vim.fn.VSCodeNotify('workbench.action.findInFiles')
  end, opts)

  vim.keymap.set('n', '<leader>n', function()
    vim.fn.VSCodeNotify('workbench.action.toggleSidebarVisibility')
  end, opts)

  -- Tab navigation
  vim.keymap.set('n', '<A-h>', function()
    vim.fn.VSCodeNotify('workbench.action.previousEditor')
  end, opts)

  vim.keymap.set('n', '<A-l>', function()
    vim.fn.VSCodeNotify('workbench.action.nextEditor')
  end, opts)

  vim.keymap.set('n', '<A-k>', function()
    vim.fn.VSCodeNotify('workbench.action.closeActiveEditor')
  end, opts)

  -- Format document
  vim.keymap.set('n', '<leader>66', function()
    vim.fn.VSCodeNotify('editor.action.formatDocument')
  end, opts)

  -- LSP-like commands
  vim.keymap.set('n', '<Leader>gd', function()
    vim.fn.VSCodeNotify('editor.action.revealDefinition')
  end, opts)

  vim.keymap.set('n', '<Leader>tr', function()
    vim.fn.VSCodeNotify('editor.action.goToReferences')
  end, opts)

  vim.keymap.set('n', '<Leader>td', function()
    vim.fn.VSCodeNotify('editor.action.showHover')
  end, opts)

  -- Diagnostics
  vim.keymap.set('n', '\\dd', function()
    vim.fn.VSCodeNotify('workbench.actions.view.problems')
  end, opts)

  vim.keymap.set('n', '<Leader>tn', function()
    vim.fn.VSCodeNotify('editor.action.marker.next')
  end, opts)

  -- Explorer navigation
  vim.keymap.set('n', '<leader>e', function()
    vim.fn.VSCodeNotify('workbench.view.explorer')
  end, opts)

else
  -- Standalone Neovim configuration

  -- Bootstrap packer if it isn't installed already.
  local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
      fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
      vim.cmd [[packadd packer.nvim]]
      return true
    end
    return false
  end

  local packer_bootstrap = ensure_packer()

  -- Plugin setup using packer.nvim.
  require('packer').startup(function(use)
    -- Packer manages itself
    use 'wbthomason/packer.nvim'

    -- Core LSP and tooling
    use 'neovim/nvim-lspconfig'

    -- Colorscheme
    use 'ku1ik/vim-monokai'

    -- Statusline
    use 'hoob3rt/lualine.nvim'

    -- Git and editing helpers
    use 'tpope/vim-fugitive'
    use 'tpope/vim-surround'
    use 'jremmen/vim-ripgrep'

    -- Lua functions used by many plugins
    use 'nvim-lua/plenary.nvim'

    -- Treesitter for enhanced syntax highlighting and indentation
    use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }

    -- Telescope and FZF integration
    use 'nvim-telescope/telescope.nvim'
    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

    -- Completion plugins
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/nvim-cmp'

    -- Formatter
    use 'mhartington/formatter.nvim'

    -- File explorer
    use 'nvim-tree/nvim-tree.lua'

    -- Claude Code integration
    use 'folke/snacks.nvim'
    use {
      'coder/claudecode.nvim',
      requires = { 'folke/snacks.nvim' },
      config = function()
        require('claudecode').setup({
          terminal = {
            provider = 'native',
            split_side = 'right',
            split_width_percentage = 0.35,
          },
        })
      end,
    }

    -- Misc
    use 'giusgad/pets.nvim'
    use 'giusgad/hologram.nvim'
    use 'stevearc/dressing.nvim'
    use 'akinsho/git-conflict.nvim'

    if packer_bootstrap then
      require('packer').sync()
    end
  end)

  -- General options
  vim.opt.background = 'dark'
  vim.opt.termguicolors = true
  vim.cmd('colorscheme monokai')

  -- Additional options
  vim.opt.path:append("**")
  vim.opt.wildignore:append("*/node_modules/*")

  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 2
  vim.opt.expandtab = true

  local opts = { noremap = true, silent = true }

  -- Fugitive Conflict Resolution
  vim.keymap.set('n', '\\3ws', ':Gdiffsplit!<CR>', opts)
  vim.keymap.set('n', 'gdh', ':diffget //2<CR>', opts)
  vim.keymap.set('n', 'gdl', ':diffget //3<CR>', opts)

  -- Completion options
  vim.opt.completeopt = {'menuone', 'noselect'}

  -- Telescope mappings
  vim.keymap.set('n', '<C-p>', "<cmd>Telescope find_files hidden=true<CR>", opts)
  vim.keymap.set('n', '\\f', "<cmd>Telescope live_grep<CR>", opts)
  vim.keymap.set('n', '\\dd', "<cmd>Telescope diagnostics<CR>", opts)
  vim.keymap.set('n', '\\\\', "<cmd>Telescope buffers<CR>", opts)
  vim.keymap.set('n', ';;', "<cmd>Telescope help_tags<CR>", opts)

  -- Nvim-tree mappings
  vim.keymap.set('n', '<C-n>', ":NvimTreeToggle<CR>", opts)
  vim.keymap.set('n', '<C-b>', ":NvimTreeFindFile<CR>", opts)

  -- Formatter mapping
  vim.keymap.set('n', '<leader>66', ":Format<CR>", opts)

  -- Tabs mappings
  vim.keymap.set('n', '<A-h>', ":tabprevious<CR>", opts)
  vim.keymap.set('n', '<A-l>', ":tabnext<CR>", opts)
  vim.keymap.set('n', '<A-k>', ":tabclose<CR>", opts)
  vim.keymap.set('n', '<A-1>', "1gt", opts)
  vim.keymap.set('n', '<A-2>', "2gt", opts)
  vim.keymap.set('n', '<A-3>', "3gt", opts)
  vim.keymap.set('n', '<A-4>', "4gt", opts)
  vim.keymap.set('n', '<A-5>', "5gt", opts)
  vim.keymap.set('n', '<A-6>', "6gt", opts)
  vim.keymap.set('n', '<A-7>', "7gt", opts)
  vim.keymap.set('n', '<A-8>', "8gt", opts)
  vim.keymap.set('n', '<A-9>', "9gt", opts)
  vim.keymap.set('n', '<A-0>', ":tablast<CR>", opts)

  -- Same tab mappings from terminal mode (e.g. Claude Code)
  vim.keymap.set('t', '<A-h>', [[<C-\><C-n>:tabprevious<CR>]], opts)
  vim.keymap.set('t', '<A-l>', [[<C-\><C-n>:tabnext<CR>]], opts)
  vim.keymap.set('t', '<A-k>', [[<C-\><C-n>:tabclose<CR>]], opts)
  vim.keymap.set('t', '<A-1>', [[<C-\><C-n>1gt]], opts)
  vim.keymap.set('t', '<A-2>', [[<C-\><C-n>2gt]], opts)
  vim.keymap.set('t', '<A-3>', [[<C-\><C-n>3gt]], opts)
  vim.keymap.set('t', '<A-4>', [[<C-\><C-n>4gt]], opts)
  vim.keymap.set('t', '<A-5>', [[<C-\><C-n>5gt]], opts)
  vim.keymap.set('t', '<A-6>', [[<C-\><C-n>6gt]], opts)
  vim.keymap.set('t', '<A-7>', [[<C-\><C-n>7gt]], opts)
  vim.keymap.set('t', '<A-8>', [[<C-\><C-n>8gt]], opts)
  vim.keymap.set('t', '<A-9>', [[<C-\><C-n>9gt]], opts)
  vim.keymap.set('t', '<A-0>', [[<C-\><C-n>:tablast<CR>]], opts)

  -- Window navigation mappings
  vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
  vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
  vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
  vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

  -- Same navigation from terminal mode (e.g. Claude Code)
  vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], opts)
  vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], opts)
  vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], opts)
  vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], opts)

  -- Resize splits
  vim.keymap.set('n', '\\+', ':vertical resize +10<CR>', opts)
  vim.keymap.set('n', '\\-', ':vertical resize -10<CR>', opts)

  -- Claude Code keymaps
  vim.keymap.set('n', '<leader>ac', '<cmd>ClaudeCode<cr>', { desc = 'Toggle Claude' })
  vim.keymap.set('n', '<leader>af', '<cmd>ClaudeCodeFocus<cr>', { desc = 'Focus Claude' })
  vim.keymap.set('n', '<leader>ar', '<cmd>ClaudeCode --resume<cr>', { desc = 'Resume Claude' })
  vim.keymap.set('n', '<leader>aC', '<cmd>ClaudeCode --continue<cr>', { desc = 'Continue Claude' })
  vim.keymap.set('n', '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', { desc = 'Select Claude model' })
  vim.keymap.set('n', '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', { desc = 'Add current buffer' })
  vim.keymap.set('v', '<leader>as', '<cmd>ClaudeCodeSend<cr>', { desc = 'Send to Claude' })
  vim.keymap.set('n', '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', { desc = 'Accept diff' })
  vim.keymap.set('n', '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', { desc = 'Deny diff' })

  -- <leader>as in file trees adds the file under cursor to Claude's context
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw' },
    callback = function(args)
      vim.keymap.set('n', '<leader>as', '<cmd>ClaudeCodeTreeAdd<cr>',
        { buffer = args.buf, desc = 'Add file to Claude' })
    end,
  })

  -- Create an autogroup and autocmd for formatting on buffer write
  vim.api.nvim_create_augroup('FormatAutogroup', { clear = true })
  vim.api.nvim_create_autocmd('BufWritePost', {
    group = 'FormatAutogroup',
    pattern = '*',
    command = 'FormatWrite'
  })

  -- LSP and completion configuration
  local cmp = require'cmp'

  cmp.setup({
    mapping = {
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        else
          fallback()
        end
      end, { 'i', 's' }),
    },
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
    }, {
      { name = 'buffer' },
    })
  })

  -- Set up cmdline completion
  cmp.setup.cmdline('/', {
    sources = {
      { name = 'buffer' }
    }
  })

  cmp.setup.cmdline(':', {
    sources = cmp.config.sources({
      { name = 'path' }
    }, {
      { name = 'cmdline' }
    })
  })

  local capabilities = require('cmp_nvim_lsp').default_capabilities(
    vim.lsp.protocol.make_client_capabilities()
  )

  -- LSP keymaps and per-client tweaks via LspAttach
  vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      local map_opts = { noremap = true, silent = true, buffer = bufnr }

      vim.keymap.set('n', '<Leader>gd', function() vim.cmd('vsplit'); vim.lsp.buf.definition() end, map_opts)
      vim.keymap.set('n', '<Leader>gD', vim.lsp.buf.declaration, map_opts)
      vim.keymap.set('n', '<Leader>tr', vim.lsp.buf.references, map_opts)
      vim.keymap.set('n', '<Leader>td', vim.diagnostic.open_float, map_opts)
      vim.keymap.set('n', '<Leader>tn', function() vim.diagnostic.jump({ count = 1, float = true }) end, map_opts)
      vim.keymap.set('n', '<Leader>ty', function() vim.lsp.buf.format({ async = false }) end, map_opts)
      vim.keymap.set('n', '<Leader>tx', function() vim.lsp.buf.format({ async = false }) end, map_opts)
      vim.keymap.set('n', '<Leader>ts', vim.lsp.buf.signature_help, map_opts)
      vim.keymap.set('n', '<C-a>', vim.lsp.buf.code_action, map_opts)

      -- ts_ls: let prettier/eslint handle formatting instead
      if client and client.name == 'ts_ls' then
        client.server_capabilities.documentFormattingProvider = false
      end

      -- eslint: fix all on save
      if client and client.name == 'eslint' then
        vim.api.nvim_create_autocmd('BufWritePre', {
          buffer = bufnr,
          command = 'EslintFixAll',
        })
      end
    end,
  })

  -- Additional plugin setups
  require('snacks').setup({})
  require('git-conflict').setup({})
  require('pets').setup({})

  -- Lualine configuration
  require('lualine').setup {
    options = {
      icons_enabled = false,
      theme = 'dracula',
    },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch'},
      lualine_c = {'filename'},
      lualine_x = {'encoding', 'fileformat', 'filetype'},
      lualine_y = {'diagnostics'},
      lualine_z = {'location'}
    },
  }

  -- Formatter configuration
  require('formatter').setup({
    filetype = {
      javascript = {
        function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)), '--single-quote'},
            stdin = true
          }
        end
      },
      javascriptreact = {
        function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)), '--single-quote'},
            stdin = true
          }
        end
      },
      svelte = {
        function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)), '--single-quote'},
            stdin = true
          }
        end
      },
      json = {
        function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))},
            stdin = true
          }
        end
      },
      typescript = {
        function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)), '--single-quote'},
            stdin = true
          }
        end
      },
      typescriptreact = {
        function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)), '--single-quote'},
            stdin = true
          }
        end
      },
    }
  })

  -- Telescope setup
  require('telescope').setup {
    defaults = { file_ignore_patterns = {".git"} },
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      }
    }
  }

  -- LSP setups for various languages (Neovim 0.11+ API)
  -- Global defaults applied to all servers
  vim.lsp.config('*', {
    capabilities = capabilities,
  })

  -- Per-server customizations
  vim.lsp.config('eslint', {
    filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx', 'vue', 'svelte', 'astro' },
  })

  -- Enable servers
  vim.lsp.enable({ 'biome', 'svelte', 'tailwindcss', 'pyright', 'graphql', 'ts_ls', 'eslint' })

  -- Treesitter configuration
  require('nvim-treesitter.configs').setup {
    highlight = {
      enable = true,
      disable = {},
    },
    indent = {
      enable = true,
      disable = {},
    },
    ensure_installed = {
      "typescript",
      "javascript",
      "tsx",
      "toml",
      "json",
      "yaml",
      "html",
      "scss",
      "css",
      "svelte",
      "python"
    },
  }

  -- Adjust parser configurations
  local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
  parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx", "typescript", "typescriptreact" }

  -- Setup nvim-tree
  vim.g.nvim_tree_show_icons = {
    folders = 1,
    files = 0,
  }

  local function on_nvim_tree_attach(bufnr)
    local api = require('nvim-tree.api')
    local opts = function(desc)
      return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end
    api.config.mappings.default_on_attach(bufnr)
    vim.keymap.set('n', 'u', api.tree.change_root_to_parent, opts('Up'))
  end

  require("nvim-tree").setup({
    on_attach = on_nvim_tree_attach,
    sort_by = "case_sensitive",
    view = {
      adaptive_size = true,
    },
    renderer = {
      group_empty = true,
    },
    filters = {
      dotfiles = false,
    },
    git = { enable = true, ignore = false, timeout = 500, }
  })

end

-- vim-surround is loaded above in the packer config and works in both environments
-- In VSCode, it provides the same cs, ds, ys commands as in standalone Neovim

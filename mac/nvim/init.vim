call plug#begin('~/.local/share/nvim/plugged')
  Plug 'neovim/nvim-lspconfig'
  Plug 'williamboman/nvim-lsp-installer'
  Plug 'phanviet/vim-monokai-pro'
  Plug 'hoob3rt/lualine.nvim'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-surround'
  Plug 'jremmen/vim-ripgrep'
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
  Plug 'hrsh7th/nvim-compe'
  Plug 'mhartington/formatter.nvim'
  Plug 'nvim-tree/nvim-tree.lua'
call plug#end()

  " General
  set clipboard=unnamedplus
  set relativenumber
  set background=dark
  set termguicolors
  colorscheme monokai_pro

  set path+=**
  set wildignore+=*/node_modules/*

  set tabstop=2
  set shiftwidth=2
  set expandtab

  " Fugitive Conflict Resolution
  nnoremap \3ws :Gdiffsplit! <CR>
  nnoremap gdh :diffget //2<CR>
  nnoremap gdl :diffget //3<CR>

  " compe
  set completeopt=menuone,noselect
  inoremap <silent><expr> <C-Space> compe#complete()
  inoremap <silent><expr> <CR>      compe#confirm('<CR>')
  inoremap <silent><expr> <C-e>     compe#close('<C-e>')

  "Telescope
  nnoremap <silent> <C-p> <cmd>Telescope find_files hidden=true<cr>
  nnoremap <silent> \f <cmd>Telescope live_grep<cr>
  nnoremap <silent> \dd <cmd>Telescope lsp_document_diagnostics<cr>
  nnoremap <silent> \\ <cmd>Telescope buffers<cr>
  nnoremap <silent> ;; <cmd>Telescope help_tags<cr>

  "nvim tree
  map <C-n> :NvimTreeToggle<CR>
  map <C-b> :NvimTreeFindFile<cr>

" Formatter
nnoremap <silent> <leader>66 :Format<CR>

augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost * FormatWrite
augroup END

"Tabs
nnoremap <C-,> :tabprevious<CR>
nnoremap <C-.> :tabnext<CR>
nnoremap <C-m> :tabclose<CR>

nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

nmap <silent>\+ :vertical resize +10<CR>
nmap <silent>\- :vertical resize -10<CR>

"autocmd BufWritePre <buffer> <cmd>EslintFixAll<CR>
autocmd BufWritePre *.tsx,*.ts,*.jsx,*.js EslintFixAll

lua << EOF
  local nvim_lsp = require 'lspconfig'
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1

  local on_attach = function(client, bufnr)
    local function buf_set_keymap(...)
      bufNumber = bufnr and bufnr or 0
      vim.api.nvim_buf_set_keymap(bufNumber, ...) 
    end  

    client.server_capabilities.document_formatting = true 
    -- Mappings.
    local opts = { noremap=true, silent=true }
    buf_set_keymap('n', '<Leader>gd', ':vsplit<cr><Cmd>lua vim.lsp.buf.definition()<CR>', opts)
    buf_set_keymap('n', '<Leader>gD', '<Cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    buf_set_keymap('n', '<Leader>tr', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
    buf_set_keymap('n', '<Leader>td', '<Cmd>lua vim.diagnostic.open_float()<CR>', opts)
    buf_set_keymap('n', '<Leader>tn', '<Cmd>lua vim.diagnostic.goto_next()<CR>', opts)
    buf_set_keymap('n', '<Leader>ty', '<Cmd>lua vim.lsp.buf.formatting_sync(nil, 5000)<CR>', opts)
    buf_set_keymap('n', '<Leader>tx', '<Cmd>lua vim.lsp.buf.formatting(nil, 5000)<CR>', opts)
    buf_set_keymap('n', '<Leader>ts', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    buf_set_keymap('n', '<C-a>', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  end

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

  require('formatter').setup({
    filetype = {
      javascript = {
        -- prettier
        function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)), '--single-quote'},
            stdin = true
          }
        end
      },
      json = {
        -- prettier
        function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0))},
            stdin = true
          }
        end
      },
      typescript = {
        -- prettier
        function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)), '--single-quote'},
            stdin = true
          }
        end
      },
      typescriptreact = {
        -- prettier
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

  require('telescope').setup {
    defaults = { file_ignore_patterns = {".git"} },
    extensions = {
      fzf = {
        fuzzy = true,                    -- false will only do exact matching
        override_generic_sorter = true,  -- override the generic sorter
        override_file_sorter = true,     -- override the file sorter
        case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
      }
    }
  }

  -- require('telescope').load_extension('fzf')

  require'nvim-treesitter.configs'.setup {
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
      "css"
    },
  }

  local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
  parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx", "typescript", "typescriptreact" }

  -- TypeScript
  nvim_lsp.tsserver.setup {
    on_attach = function(client)
      client.server_capabilities.document_formatting = false 
      on_attach(client) -- idk this was throwing errors
      flags = {
        -- This will be the default in neovim 0.7+
        debounce_text_changes = 150,
      }
    end
  }

  -- enable when eslint ca read json files :(
  nvim_lsp.eslint.setup {
    on_attach = on_attach,
    flags = {
      -- This will be the default in neovim 0.7+
      debounce_text_changes = 150,
    }
  }

  --[[
  nvim_lsp.stylelint_lsp.setup{
    settings = {
      stylelintplus = {
        -- see available options in stylelint-lsp documentation
        autoFixOnFormat = true,
        autoFixOnSave = true
      }
    }
  }
--]]
  require("nvim-tree").setup({
    sort_by = "case_sensitive",
    view = {
      adaptive_size = true,
      mappings = {
        list = {
          { key = "u", action = "dir_up" },
        },
      },
    },
    renderer = {
      group_empty = true,
    },
    filters = {
      dotfiles = false,
    },
    git = { enable = true, ignore = false, timeout = 500, }
  })


  require'compe'.setup {
    enabled = true,
    autocomplete = true,
    debug = false,
    min_length = 1,
    preselect = 'enable',
    throttle_time = 80,
    source_timeout = 200,
    resolve_timeout = 800,
    incomplete_delay = 400,
    max_abbr_width = 100,
    max_kind_width = 100,
    max_menu_width = 100,
    documentation = {
      border = { '', '' ,'', ' ', '', '', '', ' ' }, -- the border option is the same as `|help nvim_open_win|`
      winhighlight = "NormalFloat:CompeDocumentation,FloatBorder:CompeDocumentationBorder",
      max_width = 120,
      min_width = 60,
      max_height = math.floor(vim.o.lines * 0.3),
      min_height = 1,
    };

    source = {
      path = true,
      buffer = true,
      calc = true,
      nvim_lsp = true,
      nvim_lua = true,
    };
  }

  local t = function(str)
      return vim.api.nvim_replace_termcodes(str, true, true, true)
  end

  local check_back_space = function()
      local col = vim.fn.col('.') - 1
      if col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
          return true
      else
          return false
      end
  end

  _G.tab_complete = function()
    if vim.fn.pumvisible() == 1 then
      return t '<C-n>'
    elseif check_back_space() then
      return t '<Tab>'
    else
      return vim.fn['compe#complete']()
    end
  end

  vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true, noremap = true})
EOF


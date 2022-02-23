call plug#begin('~/.local/share/nvim/plugged')
  Plug 'neovim/nvim-lspconfig'
  Plug 'williamboman/nvim-lsp-installer'
  Plug 'phanviet/vim-monokai-pro'
  Plug 'hoob3rt/lualine.nvim'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-surround'
  Plug 'jremmen/vim-ripgrep'
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'nvim-lua/plenary.nvim'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
  Plug 'scrooloose/nerdtree'
  Plug 'hrsh7th/nvim-compe'
  Plug 'mhartington/formatter.nvim'
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

  " Nerdtree
  autocmd StdinReadPre * let s:std_in=1
  autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
  map <C-n> :NERDTreeToggle<CR>
  map <A-r> :NERDTreeFind<cr>
  let g:NERDTreeWinPos = "left"
  let NERDTreeShowHidden=1

  " compe
  set completeopt=menuone,noselect
  inoremap <silent><expr> <C-Space> compe#complete()
  inoremap <silent><expr> <CR>      compe#confirm('<CR>')
  inoremap <silent><expr> <C-e>     compe#close('<C-e>')

  "Telescope
  nnoremap <silent> <C-p> <cmd>Telescope find_files<cr>
  nnoremap <silent> \f <cmd>Telescope live_grep<cr>
  nnoremap <silent> \dd <cmd>Telescope lsp_document_diagnostics<cr>
  nnoremap <silent> \\ <cmd>Telescope buffers<cr>
  nnoremap <silent> ;; <cmd>Telescope help_tags<cr>
  nnoremap <silent> <leader>66 :Format<CR>

"Tabs
nnoremap <A-h> :tabprevious<CR>
nnoremap <A-l> :tabnext<CR>
nnoremap <A-k> :tabclose<CR>
nnoremap <A-1> 1gt
nnoremap <A-2> 2gt
nnoremap <A-3> 3gt
nnoremap <A-4> 4gt
nnoremap <A-5> 5gt
nnoremap <A-6> 6gt
nnoremap <A-7> 7gt
nnoremap <A-8> 8gt
nnoremap <A-9> 9gt
nnoremap <A-0> :tablast<CR>

nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l

nmap <A-C-h> :vertical resize -10<CR>
nmap <A-C-l> :vertical resize +10<CR>
nmap <A-C-j> :resize +10<CR>
nmap <A-C-k> :resize -10<CR>

"autocmd BufWritePre <buffer> <cmd>EslintFixAll<CR>

lua << EOF
  local nvim_lsp = require 'lspconfig'

  local on_attach = function(client, bufnr)
    local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end  
    local function buf_set_option(...)
      vim.api.nvim_buf_set_option(bufnr, ...)
    end

    client.resolved_capabilities.document_formatting = true 
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
    extensions = {
      fzf = {
        fuzzy = true,                    -- false will only do exact matching
        override_generic_sorter = true,  -- override the generic sorter
        override_file_sorter = true,     -- override the file sorter
        case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                         -- the default case_mode is "smart_case"
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
  parser_config.tsx.used_by = { "javascript", "typescript.tsx", "typescript", "typescriptreact" }

  -- TypeScript
  nvim_lsp.tsserver.setup {
    on_attach = function(client)
      client.resolved_capabilities.document_formatting = false 
      on_attach(client) -- idk this was throwing errors
    end
  }

  -- enable when eslint ca read json files :(
  nvim_lsp.eslint.setup {
    on_attach = on_attach,
  }

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

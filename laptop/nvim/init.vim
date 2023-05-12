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
  nnoremap <silent> \dd <cmd>Telescope diagnostics<cr>
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

    local api = require('nvim-tree.api')

    local function opts(desc)
      return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
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
      javascriptreact = {
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
      "css",
      "svelte"
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
  vim.g.nvim_tree_show_icons = {
    folders = 1,
    files = 0,
  }

  local function on_nvim_tree_attach(bufnr)
    local api = require('nvim-tree.api')

    local function opts(desc)
      return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end


    -- Default mappings. Feel free to modify or remove as you wish.
    --
    -- BEGIN_DEFAULT_ON_ATTACH
    vim.keymap.set('n', '<C-]>', api.tree.change_root_to_node,          opts('CD'))
    vim.keymap.set('n', '<C-e>', api.node.open.replace_tree_buffer,     opts('Open: In Place'))
    vim.keymap.set('n', '<C-k>', api.node.show_info_popup,              opts('Info'))
    vim.keymap.set('n', '<C-r>', api.fs.rename_sub,                     opts('Rename: Omit Filename'))
    vim.keymap.set('n', '<C-t>', api.node.open.tab,                     opts('Open: New Tab'))
    vim.keymap.set('n', '<C-v>', api.node.open.vertical,                opts('Open: Vertical Split'))
    vim.keymap.set('n', '<C-x>', api.node.open.horizontal,              opts('Open: Horizontal Split'))
    vim.keymap.set('n', '<BS>',  api.node.navigate.parent_close,        opts('Close Directory'))
    vim.keymap.set('n', '<CR>',  api.node.open.edit,                    opts('Open'))
    vim.keymap.set('n', '<Tab>', api.node.open.preview,                 opts('Open Preview'))
    vim.keymap.set('n', '>',     api.node.navigate.sibling.next,        opts('Next Sibling'))
    vim.keymap.set('n', '<',     api.node.navigate.sibling.prev,        opts('Previous Sibling'))
    vim.keymap.set('n', '.',     api.node.run.cmd,                      opts('Run Command'))
    vim.keymap.set('n', 'u',     api.tree.change_root_to_parent,        opts('Up'))
    vim.keymap.set('n', 'a',     api.fs.create,                         opts('Create'))
    vim.keymap.set('n', 'bmv',   api.marks.bulk.move,                   opts('Move Bookmarked'))
    vim.keymap.set('n', 'B',     api.tree.toggle_no_buffer_filter,      opts('Toggle No Buffer'))
    vim.keymap.set('n', 'c',     api.fs.copy.node,                      opts('Copy'))
    vim.keymap.set('n', 'C',     api.tree.toggle_git_clean_filter,      opts('Toggle Git Clean'))
    vim.keymap.set('n', '[c',    api.node.navigate.git.prev,            opts('Prev Git'))
    vim.keymap.set('n', ']c',    api.node.navigate.git.next,            opts('Next Git'))
    vim.keymap.set('n', 'd',     api.fs.remove,                         opts('Delete'))
    vim.keymap.set('n', 'D',     api.fs.trash,                          opts('Trash'))
    vim.keymap.set('n', 'E',     api.tree.expand_all,                   opts('Expand All'))
    vim.keymap.set('n', 'e',     api.fs.rename_basename,                opts('Rename: Basename'))
    vim.keymap.set('n', ']e',    api.node.navigate.diagnostics.next,    opts('Next Diagnostic'))
    vim.keymap.set('n', '[e',    api.node.navigate.diagnostics.prev,    opts('Prev Diagnostic'))
    vim.keymap.set('n', 'F',     api.live_filter.clear,                 opts('Clean Filter'))
    vim.keymap.set('n', 'f',     api.live_filter.start,                 opts('Filter'))
    vim.keymap.set('n', 'g?',    api.tree.toggle_help,                  opts('Help'))
    vim.keymap.set('n', 'gy',    api.fs.copy.absolute_path,             opts('Copy Absolute Path'))
    vim.keymap.set('n', 'H',     api.tree.toggle_hidden_filter,         opts('Toggle Dotfiles'))
    vim.keymap.set('n', 'I',     api.tree.toggle_gitignore_filter,      opts('Toggle Git Ignore'))
    vim.keymap.set('n', 'J',     api.node.navigate.sibling.last,        opts('Last Sibling'))
    vim.keymap.set('n', 'K',     api.node.navigate.sibling.first,       opts('First Sibling'))
    vim.keymap.set('n', 'm',     api.marks.toggle,                      opts('Toggle Bookmark'))
    vim.keymap.set('n', 'o',     api.node.open.edit,                    opts('Open'))
    vim.keymap.set('n', 'O',     api.node.open.no_window_picker,        opts('Open: No Window Picker'))
    vim.keymap.set('n', 'p',     api.fs.paste,                          opts('Paste'))
    vim.keymap.set('n', 'P',     api.node.navigate.parent,              opts('Parent Directory'))
    vim.keymap.set('n', 'q',     api.tree.close,                        opts('Close'))
    vim.keymap.set('n', 'r',     api.fs.rename,                         opts('Rename'))
    vim.keymap.set('n', 'R',     api.tree.reload,                       opts('Refresh'))
    vim.keymap.set('n', 's',     api.node.run.system,                   opts('Run System'))
    vim.keymap.set('n', 'S',     api.tree.search_node,                  opts('Search'))
    vim.keymap.set('n', 'U',     api.tree.toggle_custom_filter,         opts('Toggle Hidden'))
    vim.keymap.set('n', 'W',     api.tree.collapse_all,                 opts('Collapse'))
    vim.keymap.set('n', 'x',     api.fs.cut,                            opts('Cut'))
    vim.keymap.set('n', 'y',     api.fs.copy.filename,                  opts('Copy Name'))
    vim.keymap.set('n', 'Y',     api.fs.copy.relative_path,             opts('Copy Relative Path'))
    vim.keymap.set('n', '<2-LeftMouse>',  api.node.open.edit,           opts('Open'))
    vim.keymap.set('n', '<2-RightMouse>', api.tree.change_root_to_node, opts('CD'))
    -- END_DEFAULT_ON_ATTACH


    -- Mappings migrated from view.mappings.list
    --
    -- You will need to insert "your code goes here" for any mappings with a custom action_cb
    vim.keymap.set('n', 'u', api.tree.change_root_to_parent, opts('Up'))

end

  require("nvim-tree").setup({
    on_attach = on_nvim_tree_attach,
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



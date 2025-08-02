{ config, pkgs, ... }:

{
  home.file = {
    ".ideavimrc".source = ./.ideavimrc;
    ".vimrc.keymap".source = ./.vimrc.keymap;
  };

  # https://github.com/nix-community/home-manager/blob/master/modules/programs/neovim.nix
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/vim/plugins/generated.nix
    plugins = with pkgs.vimPlugins; [
      {
        plugin = dracula-nvim;
        config = # lua
        ''
          " first init
          let mapleader = "\<Space>"

          let g:dracula_colorterm = 0
          let g:dracula_italic = 0
        '';
      }
      {
        plugin = catppuccin-nvim;
        config = ''
          lua << EOF
          vim.g.catppuccin_flavour = "frappe" -- latte, frappe, macchiato, mocha
          require('catppuccin').setup {
            styles = {
              functions = { "italic" },
              keywords = { "italic" },
              variables = { "italic" },
            },
          }
          -- vim.cmd [[colorscheme catppuccin]]
          EOF
        '';
      }
      {
        plugin = everforest;
        config = ''
          lua <<EOF
          vim.cmd [[colorscheme everforest]]
          EOF
        '';
      }
      {
        plugin = nvim-surround;
        type = "lua";
        config = # lua
        ''
          require('nvim-surround').setup {}
        '';
      }
      {
        plugin = vim-fern;
        config = # lua
        ''
          nnoremap <Leader>n :Fern . -drawer -reveal=% -toggle -stay<CR>
          nnoremap <C-n> :Fern . -drawer -reveal=%<CR>
        '';
      }
      vim-devicons
      {
        plugin = vim-gitgutter;
        config = ''
        let g:gitgutter_sign_column_always = 1
        nmap ghp <Plug>(GitGutterPreviewHunk)
        nmap ghs <Plug>(GitGutterStageHunk)
        xmap ghs <Plug>(GitGutterStageHunk)
        nmap ghu <Plug>(GitGutterUndoHunk)
        '';
      }
      {
        plugin = fzf-lua;
        type = "lua";
        config = # lua
        ''
          require('fzf-lua').setup({})

          vim.keymap.set('n', '<Leader>f', '<Cmd>lua require("fzf-lua").files()<CR>')
          vim.keymap.set('n', '<Leader>/', '<Cmd>lua require("fzf-lua").grep_project()<CR>')
          vim.keymap.set('n', '<Leader>b', '<Cmd>lua require("fzf-lua").buffers()<CR>')
          vim.keymap.set('n', '<Leader>m', '<Cmd>lua require("fzf-lua").marks()<CR>')
          vim.keymap.set('n', '<Leader>j', '<Cmd>lua require("fzf-lua").jumps()<CR>')
          vim.keymap.set('n', '<Leader><tab>', '<Cmd>lua require("fzf-lua").keymaps()<CR>')

          vim.keymap.set('n', 'gd', '<Cmd>lua require("fzf-lua").lsp_definitions()<CR>')
          vim.keymap.set('n', 'gr', '<Cmd>lua require("fzf-lua").lsp_references()<CR>')
          vim.keymap.set('n', 'gD', '<Cmd>lua require("fzf-lua").lsp_declarations()<CR>')
          vim.keymap.set('n', 'gi', '<Cmd>lua require("fzf-lua").lsp_implementations()<CR>')
          vim.keymap.set('n', 'gy', '<Cmd>lua require("fzf-lua").lsp_typedefs()<CR>')
          vim.keymap.set('n', '<Leader>r', '<Cmd>lua require("fzf-lua").lsp_rename()<CR>')
          vim.keymap.set('n', '<Leader>s', '<Cmd>lua require("fzf-lua").lsp_document_symbols()<CR>')
          vim.keymap.set('n', '<Leader>S', '<Cmd>lua require("fzf-lua").lsp_live_workspace_symbols()<CR>')
          vim.keymap.set('n', '<Leader>d', '<Cmd>lua require("fzf-lua").lsp_document_diagnostics()<CR>')
          vim.keymap.set('n', '<Leader>D', '<Cmd>lua require("fzf-lua").lsp_workspace_diagnostics()<CR>')
          vim.keymap.set('n', '<Leader>a', '<Cmd>lua require("fzf-lua").lsp_code_actions()<CR>')
          '';
      }
      {
        plugin = vim-easymotion;
        config = ''
        " gf{char} to move to {char}
        map  gf <Plug>(easymotion-bd-f)
        nmap gf <Plug>(easymotion-overwin-f)

        " s{char}{char} to move to {char}{char}
        nmap s <Plug>(easymotion-overwin-f2)

        " g/{char}+ to move
        nmap g/ <Plug>(easymotion-sn)

        " Move to word
        map  gw <Plug>(easymotion-bd-w)
        nmap gw <Plug>(easymotion-overwin-w)
        '';
      }
      {
        plugin = lazygit-nvim;
        config = ''
          nnoremap <Leader>g :LazyGit<CR>
        '';
      }
      {
        plugin = toggleterm-nvim;
        type = "lua";
        config = # lua
        ''
          require('toggleterm').setup{
            size = 15,
            open_mapping = [[<C-t>]],
            start_in_insert = true,
            direction = 'float',
            close_on_exit = true,
          }
        '';
      }
      {
        plugin = barbar-nvim;
        config = ''
          nnoremap <silent> <A-,> <Cmd>BufferPrevious<CR>
          nnoremap <silent> <A-.> <Cmd>BufferNext<CR>
          nnoremap <silent> <A-w> :BufferClose<CR>
        '';
      }
      nvim-web-devicons
      {
        plugin = nvim-cmp;
        type = "lua";
        config = # lua
        ''
          local cmp = require 'cmp'
          cmp.setup({
            snippet = {
              expand = function(args)
                vim.fn["vsnip#anonymous"](args.body)
              end,
              },
              mapping = cmp.mapping.preset.insert({
                ['<C-d>'] = cmp.mapping.scroll_docs(-4),
                ['<C-f>'] = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>'] = cmp.mapping.close(),
                ['<CR>'] = cmp.mapping.confirm({
                  behavior = cmp.ConfirmBehavior.Insert,
                  select = true,
                }),
              }),
              sources = cmp.config.sources({
                { name = 'nvim_lsp' },
              }, {
                { name = 'buffer' },
              }),
          })
        '';
      }
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = # lua
        ''
          local lspconfig = require 'lspconfig'
          local capabilities = require('cmp_nvim_lsp').default_capabilities()

          lspconfig.elixirls.setup{
            capabilities = capabilities,
            cmd = { '${pkgs.elixir-ls}/bin/elixir-ls' }
          }

          lspconfig.taplo.setup{
            capabilities = capabilities,
            cmd = { '${pkgs.taplo}/bin/taplo', 'lsp', 'stdio' }
          }

          lspconfig.terraformls.setup{
            capabilities = capabilities,
            cmd = { '${pkgs.terraform-ls}/bin/terraform-ls', 'serve' }
          }

          lspconfig.bashls.setup{
            capabilities = capabilities,
            cmd = { '${pkgs.bash-language-server}/bin/bash-language-server', 'start' }
          }

          lspconfig.yamlls.setup{
            capabilities = capabilities,
            cmd = { '${pkgs.yaml-language-server}/bin/yaml-language-server', '--stdio' }
          }

          lspconfig.hls.setup{
            capabilities = capabilities,
            cmd = { '${config.home.homeDirectory}/.ghcup/bin/haskell-language-server-wrapper', '--lsp' }
          }

          lspconfig.nixd.setup{
            capabilities = capabilities,
            cmd = { '${pkgs.nixd}/bin/nixd' }
          }

          lspconfig.rust_analyzer.setup{
              settings = {
                  ["rust-analyzer"] = {
                      check = {
                          command = "clippy"
                      }
                  }
              }
          }

          vim.lsp.enable('nushell')
        '';
      }
      {
        plugin = lspsaga-nvim;
        type = "lua";
        config = # lua
        ''
          require('lspsaga').setup({})
          '';
      }
      {
        plugin = nvim-treesitter;
        type = "lua";
        config = # lua
        ''
          require('nvim-treesitter.configs').setup {
            highlight = {
              enable = true,
            },
            indent = {
              enable = true,
              disable = { 'yaml' },
            }
          }
        '';
      }
      nvim-treesitter-parsers.elixir
      nvim-treesitter-parsers.heex
      nvim-treesitter-parsers.eex
      nvim-treesitter-parsers.surface
      nvim-treesitter-parsers.terraform
      nvim-treesitter-parsers.yaml
      nvim-treesitter-parsers.toml
      nvim-treesitter-parsers.bash
      nvim-treesitter-parsers.nu
      copilot-vim
    ];

    extraConfig = ''
      source ~/.vimrc.keymap

      " --- nvim settings -----------------------
      set encoding=UTF-8
      filetype plugin indent on
      filetype plugin on
      syntax on
      set termguicolors
      set autoindent
      set expandtab
      set number
      set title
      set showmatch
      set tabstop=4
      set shiftwidth=4
      set smartindent
      set smarttab
      set matchpairs& matchpairs+=<:>
      set backspace=eol,indent,start
      set noswapfile
      set nobackup
      set viminfo=

      " --- terminal ----------------------------
      autocmd TermOpen * setlocal norelativenumber
      autocmd TermOpen * setlocal nonumber
      '';

    extraLuaConfig = '''';
  };
}

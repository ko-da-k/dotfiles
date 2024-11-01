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

    extraPackages = with pkgs; [
      bash-language-server
      taplo
      elixir-ls
      terraform-ls
      yaml-language-server
    ];

    # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/editors/vim/plugins/generated.nix
    plugins = with pkgs.vimPlugins; [
      {
        plugin = dracula-nvim;
        config = ''
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
        plugin = vim-fern;
        config = ''
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
        plugin = fzf-vim;
        config = ''
          let $FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -g ""'
          map <C-p> :Files<CR>'
          map <C-f> :Rg<CR>'
          " Mapping selecting mappings
          nmap <Leader><tab> <plug>(fzf-maps-n)'
          xmap <Leader><tab> <plug>(fzf-maps-x)'
          omap <Leader><tab> <plug>(fzf-maps-o)'
        '';
      }
      {
        plugin = vim-easymotion;
        config = ''
        " <Leader>f{char} to move to {char}
        map  <Leader>f <Plug>(easymotion-bd-f)
        nmap <Leader>f <Plug>(easymotion-overwin-f)

        " s{char}{char} to move to {char}{char}
        nmap s <Plug>(easymotion-overwin-f2)

        " g/{char}+ to move
        nmap g/ <Plug>(easymotion-sn)

        " Move to word
        map  <Leader>w <Plug>(easymotion-bd-w)
        nmap <Leader>w <Plug>(easymotion-overwin-w)
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
        config = ''
          lua <<EOF
          require('toggleterm').setup{
            size = 15,
            open_mapping = [[<C-t>]],
            start_in_insert = true,
            direction = 'float',
            close_on_exit = true,
          }
          EOF
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
        config = ''
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
        config = ''
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
        '';
      }
      {
        plugin = lspsaga-nvim;
        type = "lua";
        config = ''
          require('lspsaga').setup({})

          vim.keymap.set('n', 'gh', '<Cmd>Lspsaga finder ref<CR>')
          vim.keymap.set('n', 'gr', '<Cmd>Lspsaga project_replace<CR>')
          vim.keymap.set('n', 'gd', '<Cmd>Lspsaga peek_definition<CR>')
        '';
      }
      nvim-treesitter
      nvim-treesitter-parsers.elixir
      nvim-treesitter-parsers.heex
      nvim-treesitter-parsers.eex
      nvim-treesitter-parsers.surface
      nvim-treesitter-parsers.terraform
      nvim-treesitter-parsers.yaml
      nvim-treesitter-parsers.toml
      nvim-treesitter-parsers.bash
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

    extraLuaConfig = ''
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
  };
}

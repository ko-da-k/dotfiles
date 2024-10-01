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
        config = ''
          " first init
          let mapleader = "\<Space>"

          colorscheme dracula
          let g:dracula_colorterm = 0
          let g:dracula_italic = 0
        '';
      }
      {
        plugin = nerdtree;
        config = ''
          nnoremap <Leader>n :NERDTreeFind<CR>
          nnoremap <C-n> :NERDTreeCWD<CR>
          nnoremap <C-t> :NERDTreeToggle<CR>

          let g:NERDTreeIgnore = ['\.pyc','node_modules', '\.git$', '\.idea$', '\.vscode$', '\.history$']
          let g:NERDTreeShowHidden = 1
        '';
      }
      nerdtree-git-plugin
      {
        plugin = vim-nerdtree-syntax-highlight;
        config = ''
        let g:NERDTreeLimitedSyntax = 1
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
          map <C-p> :Files<CR>
          map <C-f> :Rg<CR>
          " Mapping selecting mappings
          nmap <Leader><tab> <plug>(fzf-maps-n)
          xmap <Leader><tab> <plug>(fzf-maps-x)
          omap <Leader><tab> <plug>(fzf-maps-o)
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
            open_mapping = [[<leader>t]],
            start_in_insert = true,
            direction = 'float',
            close_on_exit = true,
          }
          EOF
        '';
      }
      vim-terraform
      vim-nix
      vim-fish
      {
        plugin = coc-nvim;
        config = ''
          inoremap <silent><expr> <TAB> coc#pum#visible() ? coc#pum#confirm()
            \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"
          inoremap <silent><expr> <Esc> coc#pum#visible() ? coc#pum#cancel() : "\<Esc>"
        '';
      }
      coc-lists
      coc-python
      coc-yaml
      coc-toml
      coc-sh
      coc-json
      coc-html
      coc-go
      coc-fzf
      coc-docker
      coc-eslint
      coc-tsserver
      nvim-treesitter
      nvim-treesitter-parsers.elixir
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
      }
    '';
  };
}

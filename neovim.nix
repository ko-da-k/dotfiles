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
        colorscheme dracula
        let g:dracula_colorterm = 0
        let g:dracula_italic = 0
        '';
      }
      {
        plugin = nerdtree;
        config = ''
        nnoremap <Space>n :NERDTreeFocus<CR>
        nnoremap <C-n> :NERDTreeCWD<CR>
        nnoremap <C-t> :NERDTreeToggle<CR>
        nnoremap <C-f> :NERDTreeFind<CR>

        let g:NERDTreeIgnore = ['\.pyc','node_modules','.git']
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
      ctrlp-vim
      fzf-vim
      {
        plugin = vim-easymotion;
        config = ''
        " <Leader>f{char} to move to {char}
        map  <Space>f <Plug>(easymotion-bd-f)
        nmap <Space>f <Plug>(easymotion-overwin-f)

        " s{char}{char} to move to {char}{char}
        nmap s <Plug>(easymotion-overwin-f2)

        " g/{char}+ to move
        nmap g/ <Plug>(easymotion-sn)

        " Move to line
        map <Leader>L <Plug>(easymotion-bd-jk)
        nmap <Leader>L <Plug>(easymotion-overwin-line)

        " Move to word
        map  <Leader>w <Plug>(easymotion-bd-w)
        nmap <Leader>w <Plug>(easymotion-overwin-w)
        '';
      }
      vim-terraform
      vim-nix
      vim-fish
      coc-nvim
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
    ];

    extraConfig = ''
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
      set clipboard&
      set clipboard^=unnamedplus
      set matchpairs& matchpairs+=<:>
      set backspace=eol,indent,start
      set noswapfile
      set nobackup
      set viminfo=

      source ~/.vimrc.keymap
      '';
  };
}

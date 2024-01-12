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

    plugins = with pkgs.vimPlugins; [
      { 
        plugin = dracula-nvim; 
        config = ''
        colorscheme dracula
        let g:dracula_colorterm = 0
        let g:dracula_italic = 0
        '';
      }
    ];

    extraConfig = ''
      set encoding=UTF-8
      filetype plugin indent on
      filetype plugin on
      syntax on
      colorscheme dracula
      let g:dracula_colorterm = 0
      let g:dracula_italic = 0
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

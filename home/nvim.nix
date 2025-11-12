{ config, pkgs, lib, ... }:
{
  xdg.configFile."nvim" = {
    source = ../config/nvim;
    recursive = true;
  };

  programs.neovim = {
    defaultEditor = true;
    # extraPackages = [ ];
  };

  programs.vim = {
    enable = true;
    settings = {
      number = true;
      relativenumber = true;

      ignorecase = true;
      smartcase = true;

      shiftwidth = 4;
      tabstop = 4;
      expandtab = false;
      copyindent = true;

      undofile = true;
    };

    extraConfig = ''
      set clipboard=unnamedplus

      set belloff=all
      set noerrorbells
      set visualbell
      set t_vb=

      set backspace=indent,eol,start

      if exists('+viminfofile')
        set viminfofile=$XDG_STATE_HOME/vim/viminfo
      else
        set viminfo='100,n$XDG_STATE_HOME/vim/viminfo
      endif

      set directory^=$XDG_STATE_HOME/vim/swap//
      set undodir=$XDG_STATE_HOME/vim/undo
      set backupdir=$XDG_STATE_HOME/vim/backup
    '';
  };

  home.activation.ensureVimStateDirs = lib.mkAfter ''
    mkdir -p "${config.xdg.stateHome}/vim"/{swap,undo,backup}
  '';
}


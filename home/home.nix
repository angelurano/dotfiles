{ config, pkgs, lib, ... }:
{
  home.username = "angeldeb";
  home.homeDirectory = "/home/angeldeb";
  home.stateVersion = "25.05";

  xdg.enable = true;
  home.preferXdgDirectories = true;

  home.packages = with pkgs; [
    git gh

    neovim

    fastfetch ripgrep fd fzf eza bat 

    oh-my-posh oh-my-zsh

    # pkgs.neovim

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  home.sessionVariables = {
    EDITOR = lib.mkDefault "nvim";
    DOTDIR = "..";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];


  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  programs.home-manager.enable = true;

  imports = [
    ./modules/shell.nix
    ./modules/zsh.nix
    ./modules/git.nix
  ];
}

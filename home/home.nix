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
  ];

  home.sessionVariables = {
    BROWSER = "brave";
  };

  programs.home-manager.enable = true;

  imports = [
    ./modules/shell.nix
    ./modules/zsh.nix
    ./modules/git.nix
    ./modules/nvim.nix
  ];
}

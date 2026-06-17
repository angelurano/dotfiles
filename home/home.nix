{ config, pkgs, lib, antigravity-cli, ... }:
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
    wget direnv

    antigravity-cli

    oh-my-posh oh-my-zsh

    # nodejs_24 # config in shell.nix
  ];

  home.sessionVariables = {
    BROWSER = "brave";
  };

  programs.home-manager.enable = true;
}


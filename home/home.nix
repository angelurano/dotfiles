{
  config,
  pkgs,
  lib,
  antigravity-cli,
  ...
}:
{
  home.stateVersion = "25.05";

  xdg.enable = true;
  home.preferXdgDirectories = true;

  home.packages = with pkgs; [
    git
    gh

    neovim

    fastfetch
    ripgrep
    fd
    fzf
    eza
    bat
    wget
    direnv
    devenv

    antigravity-cli

    oh-my-posh
    oh-my-zsh

    nodejs_22
  ];

  home.sessionVariables = {
    BROWSER = "brave";
  };

  programs.home-manager.enable = true;
}
